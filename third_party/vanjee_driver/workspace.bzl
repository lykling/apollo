"""load vanjee driver"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def clean_dep(dep):
    return str(Label(dep))

def repo():
    http_archive(
        name = "vanjee_driver",
        sha256 = "3ce1043c44c5c07de17c5714d0ba8d98c0e2c6d8946da38ef07d22e69358b2d1",
        build_file = clean_dep("//third_party/vanjee_driver:vanjee.BUILD"),
        strip_prefix = "vanjee_driver_sdk-1.10.1",
        urls = [
            "https://github.com/wheelos/vanjee_driver_sdk/archive/refs/tags/v1.10.1.tar.gz",
        ],
    )
