all:
	pushd closure && \
	./build_java_and_js.sh && \
	popd && \
	pushd batch && \
	./build_java_batch.sh &&\
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

test: build-java
	echo CLS=${CLS} && \
	pushd test && \
	./build_java_test.sh ${CLS} &&\
	popd

batch: build-java
	echo CLS=${CLS} && \
	pushd batch && \
	./build_java_batch.sh &&\
	./run.sh ${CLS} &&\
	popd

translation:
	pushd dev-tool/translate &&\
	python3 translate_rs_properties.py &&\
	popd
