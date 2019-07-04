REPOSITORY=ontotext
VERSION=8.10.1

ee:
	docker build --build-arg edition=ee --build-arg version=${VERSION} -t ${REPOSITORY}/graphdb:${VERSION}-ee .

se:
	docker build --build-arg edition=se --build-arg version=${VERSION} -t ${REPOSITORY}/graphdb:${VERSION}-se .

ee-upload: ee
	docker push ${REPOSITORY}/graphdb:${VERSION}-ee

se-upload: se
	docker push ${REPOSITORY}/graphdb:${VERSION}-se
