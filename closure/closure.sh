java -jar ./closure-compiler-v20180805.jar --js ./js/common-11.js --js_output_file ../WebContent/js/common-11.js

#for file in $( ls ./js | grep .js$ ); do
#echo "${file}"
#java -jar ./closure-compiler-v20180805.jar --js ./js/${file} --js_output_file ../WebContent/js/${file}
#done

