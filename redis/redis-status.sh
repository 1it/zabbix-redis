#!/bin/bash

#Redis status

METRIC="$2"
SERV="$1"
DB="$3"

PORT="6379"

if [[ -z "$1" ]]; then
    echo "Please set server"
    exit 1
fi

CACHETTL="55" # Время действия кеша в секундах (чуть меньше чем период опроса элементов)
CACHE="/tmp/redis-status-`echo $SERV | md5sum | cut -d" " -f1`.cache"

if [ -s "$CACHE" ]; then
    TIMECACHE=`stat -c"%Z" "$CACHE"`
else
    TIMECACHE=0
fi

TIMENOW=`date '+%s'`

if [ "$(($TIMENOW - $TIMECACHE))" -gt "$CACHETTL" ]; then
    (echo -en "INFO\r\n"; sleep 1;) | nc -w1 $SERV $PORT > $CACHE || exit 1
fi

FIRST_ELEMENT=1
function json_head {
    printf "{";
    printf "\"data\":[";    
}

function json_end {
    printf "]";
    printf "}";
}

function check_first_element {
    if [[ $FIRST_ELEMENT -ne 1 ]]; then
        printf ","
    fi
    FIRST_ELEMENT=0
}

function databse_detect {
    json_head
    for dbname in $LIST_DATABSE
    do
        local dbname_t=$(echo $dbname| sed 's!\n!!g')
        check_first_element
        printf "{"
        printf "\"{#DBNAME}\":\"$dbname_t\""
        printf "}"
    done
    json_end
}

case $METRIC in
    'redis_version')
        grep "redis_version:" $CACHE | cut -d':' -f2
        ;;            
    'redis_git_sha1')
        grep "redis_git_sha1:" $CACHE | cut -d':' -f2
        ;;
    'redis_git_dirty')
        grep "redis_git_dirty:" $CACHE | cut -d':' -f2
        ;;
    'redis_mode')
        grep "redis_mode:" $CACHE | cut -d':' -f2
        ;;
    'arch_bits')
        grep "arch_bits:" $CACHE | cut -d':' -f2
        ;;
    'multiplexing_api')
        grep "multiplexing_api:" $CACHE | cut -d':' -f2
        ;;
    'gcc_version')
        grep "gcc_version:" $CACHE | cut -d':' -f2
        ;;
    'uptime_in_seconds')
        grep "uptime_in_seconds:" $CACHE | cut -d':' -f2
        ;;
    'lru_clock')
        grep "lru_clock:" $CACHE | cut -d':' -f2
        ;;            
    'connected_clients')
        grep "connected_clients:" $CACHE | cut -d':' -f2
        ;;
    'client_longest_output_list')
        grep "client_longest_output_list:" $CACHE | cut -d':' -f2
        ;;
    'client_biggest_input_buf')
        grep "client_biggest_input_buf:" $CACHE | cut -d':' -f2
        ;;
    'used_memory')
        grep "used_memory:" $CACHE | cut -d':' -f2
        ;;
    'used_memory_peak')
        grep "used_memory_peak:" $CACHE | cut -d':' -f2
        ;;        
    'mem_fragmentation_ratio')
        grep "mem_fragmentation_ratio:" $CACHE | cut -d':' -f2
        ;;
    'loading')
        grep "loading:" $CACHE | cut -d':' -f2
        ;;            
    'rdb_changes_since_last_save')
        grep "rdb_changes_since_last_save:" $CACHE | cut -d':' -f2
        ;;
    'rdb_bgsave_in_progress')
        grep "rdb_bgsave_in_progress:" $CACHE | cut -d':' -f2
        ;;
    'aof_rewrite_in_progress')
        grep "aof_rewrite_in_progress:" $CACHE | cut -d':' -f2
        ;;
    'aof_enabled')
        grep "aof_enabled:" $CACHE | cut -d':' -f2
        ;;
    'aof_rewrite_scheduled')
        grep "aof_rewrite_scheduled:" $CACHE | cut -d':' -f2
        ;;
    'total_connections_received')
        grep "total_connections_received:" $CACHE | cut -d':' -f2
        ;;            
    'total_commands_processed')
        grep "total_commands_processed:" $CACHE | cut -d':' -f2
        ;;
    'instantaneous_ops_per_sec')
        grep "instantaneous_ops_per_sec:" $CACHE | cut -d':' -f2
        ;;
    'rejected_connections')
        grep "rejected_connections:" $CACHE | cut -d':' -f2
        ;;
    'expired_keys')
        grep "expired_keys:" $CACHE | cut -d':' -f2
        ;;
    'evicted_keys')
        grep "evicted_keys:" $CACHE | cut -d':' -f2
        ;;
    'keyspace_hits')
        grep "keyspace_hits:" $CACHE | cut -d':' -f2
        ;;        
    'keyspace_misses')
        grep "keyspace_misses:" $CACHE | cut -d':' -f2
        ;;
    'pubsub_channels')
        grep "pubsub_channels:" $CACHE | cut -d':' -f2
        ;;        
    'pubsub_patterns')
        grep "pubsub_patterns:" $CACHE | cut -d':' -f2
        ;;             
    'latest_fork_usec')
        grep "latest_fork_usec:" $CACHE | cut -d':' -f2
        ;; 
    'role')
        grep "role:" $CACHE | cut -d':' -f2
        ;;
    'connected_slaves')
        grep "connected_slaves:" $CACHE | cut -d':' -f2
        ;;          
    'used_cpu_sys')
        grep "used_cpu_sys:" $CACHE | cut -d':' -f2
        ;;  
    'used_cpu_user')
        grep "used_cpu_user:" $CACHE | cut -d':' -f2
        ;;
    'used_cpu_sys_children')
        grep "used_cpu_sys_children:" $CACHE | cut -d':' -f2
        ;;             
    'used_cpu_user_children')
        grep "used_cpu_user_children:" $CACHE | cut -d':' -f2
        ;; 
    'key_space_db_keys')
        grep "$DB:" $CACHE |cut -d':' -f2|awk -F, '{print $1}'|cut -d'=' -f2 
        ;;        
    'key_space_db_expires')
        grep "$DB:" $CACHE |cut -d':' -f2|awk -F, '{print $2}'|cut -d'=' -f2 
        ;;
    'list_key_space_db')
        LIST_DATABSE=`grep '^db.:' $CACHE | cut -d: -f1`
        databse_detect
        ;;                                                     
    *)   
        echo "Not selected metric"
        exit 0
        ;;
esac
