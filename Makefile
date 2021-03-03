all:
	pushd closure && \
	./build_java_and_js.sh && \
	popd

clean:
	rm -rf build/jp && rm -rf WebContent/WEB-INF/classes/jp

