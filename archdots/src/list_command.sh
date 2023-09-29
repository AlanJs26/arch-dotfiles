
if [[ ${args[--unmanaged]} -eq 1 ]]; then
	pacdef package unmanaged
else
	pacdef package search ''
fi
