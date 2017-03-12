#!/bin/sh
# (c) 2017 J. Edward Durrett - jed@jedwarddurrett.com
##Set Vars
logfile=""
update=0
##Functions
undefined_vars() {
  touch patches.tmp
  printf "#!/bin/sh\n" >> patches.tmp
  chmod +x patches.tmp
  cat $logfile | grep "Undefined variable" | awk '{print $15, $17}' | sort -n | uniq | while read 'file_url'; do
    udv=`echo $file_url | awk '{print $1}'`
    file=`echo $file_url | awk '{print $2}'` 
    printf "define $udv in $file \n" >> fix.tmp
    count=0
    grep $udv== $file | cut -d '=' -f3 | tr -d ') {' | sort -n |uniq | while read allowed_var; do
      if [ $count -gt 0 ]; then
        allowed_string="$allowed_string||isset(_\$POST[qqq_qqq'$udv'qqq_qqq])==$allowed_var"
        count=$((count+1))
      else
        allowed_string=$allowed_var
        count=$((count+1))
      fi
      printf "$allowed_string" > $udv.tmp
      done
      if [ -f $udv.tmp ]; then
        allowed_string=`cat $udv.tmp`
        rm $udv.tmp
        printf "awk '/DECLAREDVARS/{print; print \"\$$udv = isset(\$_POST[qqq_qqq'$udv'qqq_qqq]) & isset(\$_POST[qqq_qqq'$udv'qqq_qqq])==$allowed_string ? isset(\$_POST[qqq_qqq'$udv'qqq_qqq]) : Q_Q ;\" ; next}1' $file > $file-new \n" >> patches.tmp
        printf "sed -i -e 's/Q_Q/\"\"/' $file-new \n" >> patches.tmp
        printf "sed -i -e \"s/qqq_qqq/\'/g\" $file-new \n" >> patches.tmp
        backup_string=`date "+%Y%m%d%H%M%S"`
        printf "mv $file $file-$backup_string \n" >> patches.tmp
        printf "mv $file-new $file \n" >> patches.tmp
      fi
  done
}

##Actions

case $1 in
  verbose)
    printf "Creating patches for undefined variables from log file\n"
    undefined_vars
    cat fix.tmp | more
    cat patches.tmp | more
    printf "About to write patches. Do you wish to (c)ontinue or (a)bort?"
    read ca
      case $ca in
        A|a)
          rm fix.tmp
          rm patches.tmp
          exit 1
          ;;
        C|c)
          printf "Applying patches. Be sure to manually remove backup files once everything checks out.\n"
          ./patches.tmp 
          printf "Backup files are in webroot, you don't want these sitting around.\n\n\n"
          rm fix.tmp
          rm patches.tmp
          ;;
      esac  
    ;;
  silent)
    ;;
  fix)
    ;;
  *) 
    printf "\n\nUsage: fixer_script.sh fix|silent|verbose\n"
    printf "\nfix: Fixes a static file without looking at logs. Not implemented.\n\n"
    printf "silent: Fixes files from cron without user intervention. This could be dangerous.\n"
    printf "To implement silent mode, move the functions you want into the silent case.\n"
    printf "This is not recommended for a production system. Test, test, test!\n\n"
    printf "verbose: Looks at logs specified in the script variable logfile and fixes common PHP\n"
    printf "programming errors. This has been designed for one specific use case. Make sure you back up \n"
    printf "and test before using this script!\n\n"
    printf "In order for this script to work, a marker needs to be in the php file.\n"
    printf "Save some time, use sed to add marker. Google sed substitution for examples\n"
    printf "Markers are:\n\n"
    printf "//DECLAREDVARS - This marker is where variable declarations go.\n\n"
    ;;
  esac

