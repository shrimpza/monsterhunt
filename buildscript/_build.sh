#!/bin/bash

SCRIPTS_DIR=$(dirname $(realpath $0))

source "$SCRIPTS_DIR/buildconfig.sh"

MUSTACHE="${MUSTACHE?-mustache}"
PACKAGE_SRC_DIR=${PACKAGE_SRC_DIR?-$package}
PACKAGE_RES_DIR=${PACKAGE_RES_DIR?-"$package/resources"}

TMP_YML="$(mktemp)"
TMP_INI="$(mktemp)"

packagedir="."

cleanup() {
		( cd "$utdir" && rm -r "$packagefull" )
}

( # Subshell to preserve original working dir
		cat "$makeini">"$TMP_INI"
		echo EditPackages="$packagefull">>"$TMP_INI"

		cd "$utdir"

		( # Subshell to exit early on error, to go right into cleanup
				set -e

				mkdir "$packagefull"

				# Build temporary YAML file
				echo "build: '$build'" > "$TMP_YML"
				echo "name: '$name'" > "$TMP_YML"
				echo "version: '$version'" >> "$TMP_YML"
				echo "package: '$packagefull'" >> "$TMP_YML"
				echo "debug: '$debug'" >> "$TMP_YML"

				if [[ "$debug" == 1 ]]; then
						echo "namesuffix: ' ($build)'" >> "$TMP_YML"
				else
						echo "namesuffix: ''" >> "$TMP_YML"
				fi

				echo >> "$TMP_YML"
				cat "$PACKAGE_SRC_DIR/template-options.yml" >> "$TMP_YML"

				# Copy assets
				for asset in Models Textures Sounds; do
						if [[ -d "$PACKAGE_SRC_DIR/$asset" ]]; then
						cp -rv "$PACKAGE_SRC_DIR/$asset" "$packagefull"
						fi
				done

				# Format classes with Mustache
				mkdir "$packagefull"/Classes

				for class in "$PACKAGE_SRC_DIR"/Classes/**; do
						class="$(basename "$class")"
						echo "Formatting: $packagefull/Classes/$class"
						"$MUSTACHE" "$PACKAGE_SRC_DIR/Classes/$class" < "$TMP_YML" > "$packagefull/Classes/$class"
				done

				# Build .u
				(
						cd System
						#WINEPREFIX="$wineprefix" wine "$umake" "$package-$build"
						if [[ -f "$packagefull.u" ]]; then rm "$packagefull.u"; fi
						echo "* Invoking ucc make in $(pwd)"
						"$ucc" make -NoBind ini="$TMP_INI" | tee "$packagedir/make.log"

						# Ensure .u is built
						if [[ ! -f "$packagefull.u" ]]; then
								if [[ -f "$HOME/.utpg/System/$packagefull.u" ]]; then
										mv "$HOME/.utpg/System/$packagefull.u" .

								else
										exit 1
								fi
						fi
				)
				code=$?; [[ $code == 0 ]] || exit $code

				# Create the final package template directory
				PACKAGED="$packagefull"/packaged
				mkdir -p "$PACKAGED"/System

				# Format localisation files
				echo "Formatting localised files: $PACKAGE_RES_DIR"
				if [[ -d $PACKAGE_RES_DIR ]]; then
					for res in "$PACKAGE_RES_DIR"/System/*; do
						res="$(basename "$res")"
						if [[ $res == 'LocalisationTemplates' ]]; then continue; fi
						"$MUSTACHE" "$PACKAGE_RES_DIR/System/$res" < "$TMP_YML" > "$PACKAGED"/System/"$res"
					done
				fi

				# Overlay additional resources if present
				echo "Copy resources directory: $PACKAGE_RES_DIR"
				if [[ -d $PACKAGE_RES_DIR ]]; then
					for res in "$PACKAGE_RES_DIR"/**; do
						res="$(basename "$res")"
						if [[ $res == 'System' ]]; then continue; fi
						cp -rvf "$PACKAGE_RES_DIR/$res" "$PACKAGED/$res"
					done
				fi

				# Move over system files
				mv -v "System/$packagefull.u" "$PACKAGED"/System

				echo "Packaging up..."
				(
					cd $PACKAGED

					zip -9r "../../$packagedist.zip" ./* >/dev/null
					tar cf "../../$packagedist.tar" ./*
					gzip --best -k "../../$packagedist.tar"
					rm "../../$packagedist.tar"
				)

				# Move to dist
				mkdir -p "$dist/$package/$build"
				mv "$packagedist."{tar.*,zip} "$dist/$package/$build"

				# Update dist/latest
				echo "Organizing dist directory..."
				mkdir -p "$dist/$package/latest"
				rm -f "$dist/$package/latest/"*
				cp "$dist/$package/$build/"* "$dist/$package/latest"
		)
		exit $?
)
code=$?

# Finish up

rm "$TMP_YML"
rm "$TMP_INI"

echo "Cleaning up..."
cleanup

exit $code
