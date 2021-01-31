/bin/rm ../WebContent/js/common-*.js
#/bin/rm ../WebContent/js/commonPc-*.js
#/bin/rm ../WebContent/js/upload-*.js
#/bin/rm ../WebContent/js/update-*.js

/bin/cp ./js/common-46.js ../WebContent/js/
#/bin/cp ./js/commonPc-03.js ../WebContent/js/
#/bin/cp ./js/upload-30.js ../WebContent/js/
#/bin/cp ./js/update-07.js ../WebContent/js/

java -jar ./closure-compiler-v20201006.jar --js ./js/common-46.js --js_output_file ../WebContent/js/common-46.js
#java -jar ./closure-compiler-v20201006.jar --js ./js/commonPc-03.js --js_output_file ../WebContent/js/commonPc-03.js
#java -jar ./closure-compiler-v20201006.jar --js ./js/upload-30.js --js_output_file ../WebContent/js/upload-30.js
#java -jar ./closure-compiler-v20201006.jar --js ./js/update-07.js --js_output_file ../WebContent/js/update-07.js

##for file in $( ls ./js | grep .js$ ); do
#echo "${file}"
#java -jar ./closure-compiler-v20201006.jar --js ./js/${file} --js_output_file ../WebContent/js/${file}
#done
