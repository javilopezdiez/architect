#!/bin/bash
# Usage: gradle-select 4.10.2

VERSION=$1
if [ -z "$VERSION" ]; then
    echo "Usage: gradle-select <version>"
    exit 1
fi

export PATH="/opt/gradle/gradle-$VERSION/bin:$PATH"
echo "Switched Gradle to version $VERSION"
gradle --version
