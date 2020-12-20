function Install-Emsdk {
	git clone https://github.com/emscripten-core/emsdk.git
	sl emsdk
	./emsdk install latest
	./emsdk activate latest
	emcc --version
}
