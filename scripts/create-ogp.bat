 @echo off
 tcardgen ^
   --fontDir ./static/fonts/Kinto_Sans ^
   --output static/images/og ^
   --template static/images/ogp_template.png ^
   --config scripts/tcardgen.yaml ^
   %1
echo meta_image = "images/og/%~n1.png"