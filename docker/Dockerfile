FROM golang:1.23-alpine as build-env
RUN apk add make git
RUN mkdir /build
ADD . /build/
WORKDIR /build
RUN make build

FROM gcr.io/distroless/static:nonroot
USER 65532:65532

EXPOSE 3000
ENV GODEBUG netdns=go

COPY --from=build-env /build/drone-convert-pathschanged /usr/local/bin/drone-convert-pathschanged

ENTRYPOINT ["/usr/local/bin/drone-convert-pathschanged"]