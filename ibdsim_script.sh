#!/bin/bash

set -e

VERSION="1.12.4"



print_options() {
	echo "--genproofs or --genhist"
	echo "if go is installed ignore OPTIONS: --yes if need to download testnet txo history"
	echo "OPTIONS:"
	echo -e "  --linux install linux version"
	echo -e "  --win install windows version"
	echo -e "  --mac install macOS version"
}

if [ "$1" == "--help" ]; then 
	print_options
	exit 0
fi

VAR=$1

run_ibdsim() {
    go get "github.com/mit-dci/utreexo/cmd/ibdsim"
    cd "$HOME/go/src/github.com/mit-dci/utreexo/cmd/ibdsim"
    go build
    if [ "$VAR" == "--genproofs" ]; then
	echo "hi"
    	./ibdsim --ttlfn=$HOME/ttl.testnet3.txos --genproofs=true
    fi
    if [ "$VAR" == "--genhist" ]; then
    	./ibdsim --ttlfn=$HOME/ttl.testnet3.txos --genhist=true
    fi
    exit 0    
}

if [ -d "$HOME/.go" ] || [ -d "$HOME/go" ]; then
    echo "The 'go' or '.go' directories already exist."
    
    if [ "$2" == "--yes" ]; then 
    	echo "downloading txo history... in $HOME"

    	wget   -P "$HOME"

    fi  
    
    run_ibdsim
fi

if [ "$2" == "--linux" ]; then 
	GOFILE="go$VERSION.linux-amd64.tar.gz"
elif [ "$2" == "--win" ]; then 
        GOFILE="go$VERSION.windows-amd64.msi"
elif [ "$2" == "--mac" ]; then 
        GOFILE="go$VERSION.darwin-amd64.pkg"
else 
	print_options
	exit 1
fi

if [ $? -ne 0 ]; then
    echo "Download failed"
    exit 1
fi

echo "Downloading $GOFILE ..."
if [ "$2" == "--linux" ]; then
        wget https://golang.org/dl/$GOFILE -O /tmp/go.tar.gz
elif [ "$2" == "--win" ]; then
        wget https://golang.org/dl/$GOFILE -O /tmp/go.msi
elif [ "$2" == "--mac" ]; then
        wget https://golang.org/dl/$GOFILE -O /tmp/go.pkg
fi

if [ $? -ne 0 ]; then
    echo "Download failed"
    exit 1
fi

echo "Extracting File..."

if [ "$2" == "--linux" ]; then
	tar -C "$HOME" -xzf /tmp/go.tar.gz
	mv "$HOME/go" "$HOME/.go"
	touch "$HOME/.${shell_profile}"
elif [ "$2" == "--win" ]; then
	msiexec /a "$HOME" /qb "TARGETDIR=C:\tmp\go.msi"
	mv "$HOME/go" "$HOME/.go"
        touch "$HOME/.${shell_profile}"
elif [ "$2" == "--mac" ]; then
	xar -C "$HOME" -xzf /tmp/go.tar.gz
        mv "$HOME/go" "$HOME/.go"
        touch "$HOME/.${shell_profile}"
fi

mkdir -p $HOME/go/{src,pkg,bin}
echo -e "\nGo $VERSION was installed.\n relogin shell environment and run the script w/o setup environment"
rm -f /tmp/go.tar.gz
rm -f /tmp/go.msi
rm -f /tmp/go.pkg
