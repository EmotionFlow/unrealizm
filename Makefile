all:
	pushd closure && \
	./build_java_and_js.sh && \
	popd

build-java:
	pushd closure && \
	./build_java.sh && \
	popd

build-closure:
	pushd closure && \
	./closure.sh && \
	popd

clean:
	rm -rf WebContent/WEB-INF/classes/jp

release:
	pushd deploy && ./deploy.sh && popd
