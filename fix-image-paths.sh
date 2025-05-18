#!/bin/bash

POSTS_DIR="./_posts"
IMG_PATH="/assets/img/headers"

for mdfile in "$POSTS_DIR"/*.md; do
  filename=$(basename "$mdfile" .md)
  new_image="${IMG_PATH}/${filename}.jpg"

  echo "Updating $mdfile → $new_image"
  
  # Replace the existing image path line
  sed -i "/^image:/,/^alt:/s|path: .*|path: $new_image|" "$mdfile"
done
