BEGIN {
	max_node = 2000;
	nSentPackets = 0.0 ;		
	nReceivedPackets = 0.0 ;
	rTotalDelay = 0.0 ;
	max_pckt = 10000;
	idHighestPacket = 0;
	idLowestPacket = 100000;
	rStartTime = 10000.0;
	rEndTime = 0.0;
	nDropPackets = 0.0;
	
	for (i=0; i<max_node; i++) {
		nReceivedBytes[i]=0 ;
		rThroughput[i]=0 ;		
	}
}

{
	strEvent = $1 ;			
	rTime = $2 ;
	node = $3 ;
	strAgt = $4 ;			
	idPacket = $6 ;
	strType = $7 ;			
	nBytes = $8;
	sub(/^_*/, "", node);
	sub(/_*$/, "", node);

	if ( strAgt == "AGT"   &&   strType == "tcp" ) {
		if (idPacket > idHighestPacket) idHighestPacket = idPacket;
		if (idPacket < idLowestPacket) idLowestPacket = idPacket;

		if(rTime>rEndTime) rEndTime=rTime;
		if(rTime<rStartTime) rStartTime=rTime;

		if ( strEvent == "r" && idPacket >= idLowestPacket) {		
			nReceivedBytes[node] += nBytes;
		}
	}


}

END {
	rTime = rEndTime - rStartTime ;
	
	for(i=0; i<60;i++) {
		rThroughput[i] = nReceivedBytes[i]*8 / rTime;	
		printf( "%d %15.2f\n", i,rThroughput[i]) > "graph.txt" ;
	}
}

