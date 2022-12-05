#!/bin/sh

usage() {
  printf "hw2.sh -i INPUT -o OUTPUT [-c csv|tsv] [-j]\n\n"
  printf "Available Options:\n\n"
  printf "\-i: Input file to be decoded\n"
  printf "\-o: Output directory\n"
  printf "\-c csv|tsv: Output files.[ct]sv\n"
  printf "\-j: Output info.json\n"
  exit 1
}

set_variable() {
  local varname=$1
  shift
  eval "$varname=\"$@\""
}

####main####
unset INPUT_FILE OUTPUT_DIR OUTPUT_FILE INFO_JSON

while getopts ":i:o:c:j" option;
do
  case $option in
    i)
      set_variable INPUT_FILE $OPTARG
      ;;
    o)
      set_variable OUTPUT_DIR $OPTARG
      ;;
    c)
      set_variable OUTPUT_FILE $OPTARG
      ;;
    j)
      set_variable INFO_JSON 1
      ;;
    *)
      usage>&2
  esac
done

[ -z "$INPUT_FILE" ] && usage
[ -z "$OUTPUT_DIR" ] && usage

if [ -z "$INPUT_FILE" ] || ! [ -e $INPUT_FILE ]; then
  echo "-i: Input file to be decoded" >&2
  exit 1
fi

if ! [ -d $OUTPUT_DIR ]; then
  mkdir -p "$OUTPUT_DIR"
fi

files_array=$(jq '.["files"]' "$INPUT_FILE")
files_len=$(echo "$files_array" | jq length)
#echo "$files_array"
#echo "$files_len"
total=0

OUTPUT_PATH="${OUTPUT_DIR}/files.${OUTPUT_FILE}"

if [ "$OUTPUT_FILE" = csv ]; then
  printf "filename,size,md5,sha1\n" >> "$OUTPUT_PATH"
fi

if [ "$OUTPUT_FILE" = tsv ]; then
  printf "filename\tsize\tmd5\tsha1\n" >> "$OUTPUT_PATH"
fi

for i in $(seq 0 $(($files_len-1)))
do
  file=$(echo $files_array | jq ".[$i]")
  name=$(echo $file | jq ".name")
  dir_name=$(dirname "$name" | tr -d '"')
  file_name=$(basename "$name" | tr -d '"')
  dir_name="${OUTPUT_DIR}/${dir_name}"

  #echo "$dir_name"
  if ! [ -d "$dir_name" ]; then
    mkdir -p "$dir_name"
  fi

  file_path="${dir_name}/${file_name}"

  echo "$file" | jq ".data" | tr -d '"' | base64 -d >> "$file_path"
  md5=$(echo $(md5sum "$file_path") | awk -F' ' '{print $1}')
  sha1=$(echo $(sha1sum "$file_path") | awk -F ' ' '{print $1}')
  if ! [ $md5 = $(echo "$file" | jq ".hash.md5" | tr -d '"') ]; then
    total=$(($total + 1))
    #echo $md5
    echo "$file" | jq ".hash.md5" | tr -d '"'
  elif ! [ $sha1 = $(echo "$file" | jq '.hash."sha-1"' | tr -d '"') ]; then
    total=$(($total + 1))
    #echo $sha1
    echo "$file" | jq '.hash.["sha-1"' | tr -d '"'
  fi



  if [ -n "$OUTPUT_FILE" ]; then
    size=$(wc -c $file_path | awk '{print $1}')
    if [ "$OUTPUT_FILE" = csv ]; then
      echo "$(echo $file | jq '.name' | tr -d '"'),$size,$md5,$sha1" >> "$OUTPUT_PATH"
    fi
    
    if [ "$OUTPUT_FILE" = tsv ]; then
      printf "$(echo $file | jq '.name' | tr -d '"')\t$size\t$md5\t$sha1\n" >> "$OUTPUT_PATH"
    fi
  fi
done

if [ "$INFO_JSON" -eq 1 ]; then
  
  AUTH_BODY=$(jq -n --arg name $(jq '.name' "$INPUT_FILE" | tr -d '"') \
  --arg author $(jq '.author' "$INPUT_FILE" | tr -d '"') \
  --arg date $(date -Iseconds -r $(jq '.date' "$INPUT_FILE")) \
  '{"name": $name, "author": $author, "date": $date}')
  echo $AUTH_BODY >> "${OUTPUT_DIR}/info.json"
fi
exit $total

