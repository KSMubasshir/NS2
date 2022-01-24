set ns [new Simulator]

$ns color 0 red
$ns color 1 blue

#set namf [open queue.nam w]
set nsf [open queue.ns w]
#$ns namtrace-all $namf
$ns trace-all $nsf

set qsize13 [open queuesize13.tr w]
set qsize01 [open queuesize01.tr w]
set qsize21 [open queuesize21.tr w]

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

$n1 label "Switch (25)"

proc finish {} {
    global ns qsize13 qsize01 qsize21
    $ns flush-trace
    close $qsize13 
    close $qsize01 
    close $qsize21
    exec xgraph queuesize13.tr  -t "Queuesize" &
    exec xgraph queuesize01.tr  -t "Queuesize" &
    exec xgraph queuesize21.tr  -t "Queuesize" &
    exit 0
}

set old_departure 0

proc record {} {
global ns qmon_size13 qmon_size01 qmon_size21 qsize13 qsize01 qsize21 old_departure
set ns [Simulator instance]
set time 0.05
set now [$ns now]

$qmon_size13 instvar size_ pkts_ barrivals_ bdepartures_ parrivals_ pdepartures_ bdrops_ pdrops_ 
$qmon_size01 instvar size_ pkts_ barrivals_ bdepartures_ parrivals_ pdepartures_ bdrops_ pdrops_
$qmon_size21 instvar size_ pkts_ barrivals_ bdepartures_ parrivals_ pdepartures_ bdrops_ pdrops_ 
puts $qsize13 "$now [$qmon_size13 set size_]"
puts $qsize01 "$now [$qmon_size01 set size_]"
puts $qsize21 "$now [$qmon_size21 set size_]"

$ns at [expr $now+$time] "record"
}

#On cree les liens
$ns duplex-link $n1 $n3 1.5Mb 10ms DropTail
$ns duplex-link $n0 $n1 5Mb 10ms DropTail
$ns duplex-link $n2 $n1 5Mb 10ms DropTail

$ns duplex-link-op $n1 $n3 orient right
$ns duplex-link-op $n0 $n1 orient right-down
$ns duplex-link-op $n2 $n1 orient right-up
$ns duplex-link-op $n1 $n3 queuePos 0.5
$ns queue-limit $n1 $n3 25
$ns duplex-link-op $n0 $n1 queuePos 0.5
$ns queue-limit $n0 $n1 25
$ns duplex-link-op $n2 $n1 queuePos 0.5
$ns queue-limit $n2 $n1 25

set tick 0.5
set tcp0 [$ns create-connection TCP $n0 TCPSink $n3 0]
$tcp0 set packetSize_ 1460
$tcp0 set tcpTick_ $tick
$tcp0 set fid_ 0

#Create a CBR traffic source and attach it to tcp0
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 1460
$cbr0 set rate_ 1200k
$cbr0 attach-agent $tcp0

set tcp1 [$ns create-connection TCP $n2 TCPSink $n3 1]
$tcp1 set packetSize_ 1460
$tcp1 set tcpTick_ $tick
$tcp1 set fid_ 1
#Create a CBR traffic source and attach it to tcp1
set cbr1 [new Application/Traffic/CBR]
$cbr1 set packetSize_ 1460
$cbr1 set rate_ 1200k
$cbr1 attach-agent $tcp1

####################
# QUEUE MONITOR    #
####################

set qf_size13 [open queue13.size w]
set qmon_size13 [$ns monitor-queue $n1 $n3 $qf_size13 0.05]

set qf_size01 [open queue01.size w]
set qmon_size01 [$ns monitor-queue $n0 $n1 $qf_size01 0.05]

set qf_size21 [open queue21.size w]
set qmon_size21 [$ns monitor-queue $n2 $n1 $qf_size21 0.05]

$ns at 0.0 "record"
$ns at 0.1 "$cbr0 start"
$ns at 0.5 "$cbr1 start"
$ns at 5.1 "$cbr0 stop"

$ns at 5.5 "$cbr1 stop"

#Call the finish procedure after 5 seconds of simulation time
$ns at 5.5 "finish"

#Run the simulation
$ns run
