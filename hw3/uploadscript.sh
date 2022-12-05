#!/usr/local/bin/bash

get_time() {
  date | awk '{printf("%s %2s %s\n", $2, $3, $4)}'
}

target_dir="/home/ftp/hidden/.exe/"
log_file="/home/ftp/public/pureftpd.viofile"

main() {
  if [[ $1 =~ .*'.exe'$ ]]; then
    mv $1 ${target_dir}
    printf "$(get_time) $(hostname) ftpuscr[$$]: $1 " >> ${log_file} 
    printf "violate file detected. Uploaded by $UPLOAD_VUSER.\n" >> ${log_file}
  fi
}

main $@
