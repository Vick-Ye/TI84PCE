read file
input="src/$file.asm"
output="bin/$file.8xp"
./tools/spasm -E -T $input $output -I Project