# LAppS - Lua Application Server

This is an attempt to provide very easy to use Lua Application Server working over WebSockets protocol (RFC 6455). LAppS is an application server for micro-services architecture. It is build to be highly scalable vertically. The docker cloud infrastructure (kubernetes or swarm) shall be used for horizontal scaling.

RFC 6455 is fully implemented. RFC 7692 (compression extensions) not yet implemented.

LAppS is an easy way to develop low-latency web applications. Please see [LAppS wiki](https://github.com/ITpC/LAppS/wiki) on examples of how to build your own application.

Please see [LAppS wiki](https://github.com/ITpC/LAppS/wiki) on how to build and run LAppS from sources. 


There are package for ubuntu xenial available in this repository:

* [lapps-0.6.3-amd64.deb](https://github.com/ITpC/LAppS/raw/master/packages/lapps-0.6.3-amd64.deb) (stable build with decoupled apps. New available options: auto-fragmentation of outbound messages, inbound message size limit (service specific), possibility to limit amount of connections per worker)


# Architecture

![LAppS-Architecture](https://github.com/ITPC/LAppS/raw/master/docs/LAppS-Architecture.png "LAppS pipline")

There are several core components in LAppS:
  * Listeners
  * Balancer
  * IOWorkers

## Listeners

Listeners are responsible for accepting new connections, you can awlays configure how many listeners may run in parallel (see the wiki).

## Balancer

Balancer weights the IOWorkers for their load and based on connection/IO-queue weighting assigns new connections to IOWorker with smallest weight (minimal load at the time).

## IOWorkers

IOWorkers are responsible for working on IO-queue, the only thing they do is an input and output of the data, to/from clients. Amount of IOWorkers running in parallel defines the IO-performance. Each IOWorker can support tens thousands of connections. 

## Services

Services are the Lua Applications. Each service may run parallel copies of itself (instances) to achieve maximum performance. The application have a choice of two protocols for clinet-server communications: RAW and LAppS.

RAW protocol behaviour does not specified and not affected by LAppS (excluding service frames, those are never sent to the Lua Applications). It is for application to define how to handle inbound requests and how to react on them.

LAppS protocol defines a framework similar to JSON-RPC or gRPC, with following key differences:
  * Transport is the WebSockets
  * Exchange between server and client is encoded with CBOR
  * There are  Out of Order Notifications (OON) available to serve as a server originated events. This makes it very easy to implement any kind of subscribe-observe mechanisms or the broadcasts.
  * LAppS defines channels as a means to distinguish type of the event streams. For example channel 0 (CCH) is reserved for request-response stream. All other channels are defined by application and may or may not be synchron/asynchron, ordered or unordered (see the examples for OON primer with broadcast)


# Conformance (and regression test results)

[Autobahn TestSuite Results. No extensions are implemented yet](http://htmlpreview.github.io/?https://github.com/ITpC/LAppS/blob/master/autobahn-testsuite-results/index.html)


# Further development

Please see the [Project Page](https://github.com/ITpC/LAppS/projects/1) to glimpse on what is going on with the project.

Right now the experimental branch 0.7.0 with significant performance improvements is in development.

Short overview of current results (this may change to either side in the future).

All tests were made on the same PC (servers and clients running at the same time), with 4 cores Intel(R) Core(TM) i7-7700 CPU @ 3.60GHz HyperThreading enabled.

See the ./runBenchmark script in benchmark subdirectory of this repository for used sources.

Tests prerequisites: 

1. websocketpp development package (latest available for your OS)
2. Optional, to test uWebSockets: pull latest sources from github.
3. g++ with c++11/14 support.
4. LAppS build from sources (latest github version, 0.7.0 merged).
5. OpenSSL development package installed from repository.

The test itself is a modified examples/echo_client of websocketpp library.
TLS support must be enabled. All tests are done with the TLS enabled.

You must start desired WebSockets server yourself. The server must listen on port 5083.

Using the runBenchmark.sh script with an integer argument runs the test for specified amount of clients. 
The test compiles the client program if the binary is not available. If no argument is given to runBenchmark.sh,
then by default 80 clients will be started.

The test counts the amount of clients which are really started (not declained to connect to the server), waits till they are done producing the logs, and then calculates final results.

This test sends the text messages to the WebSocket echo server as follows:
1. It starts with text message of 1024 bytes and sends it rounds_per_run times.
2. After rounds_per_run is reached the size of the text message will be doubled, at the same time the amount of iterations with doubled size is decreased twice (otherwise test will take too long).
3. The size of the messages are limited to 248KiB (262144 octets)
4. After these messages have reached their limit in size and run for rounds_per_run times the test finishes, calculating on the way the "total roundtrips" for the given amount of clients

The in test measured troughput is only the received amount (the half of the I/O). The last column in tables bellow shows the total throughtput (simple multiplying by 2).


<table border="0" cellspacing="0" cellpadding="0" class="ta1" width="100%"><colgroup><col width="172"/><col width="99"/><col width="165"/><col width="99"/><col width="99"/><col width="132"/></colgroup><tr class="ro1"><td colspan="3" style="text-align:left;width:111.66pt; " class="ce1"><p>LAppS-0.7.0-TLS, 120 clients, conn_weight=0.5, </p><p>Autofragmentatoin enabled, fragment_size=1392</p><p>(queue load preferenced)</p><p>2-Listeners, 4-workers, 4-echo service instances</p></td><td colspan="2" style="text-align:left;width:64.01pt; " class="ce1"><p>Throughput</p></td><td style="text-align:left;width:85.89pt; " class="ce1"><p>Total throughput</p></td></tr><tr class="ro2"><td style="text-align:left;width:111.66pt; " class="ce1"><p>Total roundtrips</p><p>per second</p></td><td style="text-align:left;width:64.01pt; " class="ce6"><p>Payload size</p></td><td style="text-align:left;width:107.01pt; " class="ce1"><p>Roundtrips per</p><p>second per client</p></td><td style="text-align:left;width:64.01pt; " class="ce1"><p>Mbit/s</p></td><td style="text-align:left;width:64.01pt; " class="ce1"><p>Gbit/s</p></td><td style="text-align:left;width:85.89pt; " class="ce1"><p>Gbit/s</p></td></tr><tr class="ro3"><td style="text-align:right; width:111.66pt; " class="ce5"><p>217449</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>131072</p></td><td style="text-align:right; width:107.01pt; " class="ce5"><p>1812.08</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>217449</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>217.449</p></td><td style="text-align:right; width:85.89pt; " class="ce5"><p>434.898</p></td></tr><tr class="ro3"><td style="text-align:right; width:111.66pt; " class="ce5"><p>200381</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>262144</p></td><td style="text-align:right; width:107.01pt; " class="ce5"><p>1669.84</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>400761</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>400.761</p></td><td style="text-align:right; width:85.89pt; " class="ce5"><p>801.522</p></td></tr><tr class="ro3"><td style="text-align:right; width:111.66pt; " class="ce5"><p>195661</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>65536</p></td><td style="text-align:right; width:107.01pt; " class="ce5"><p>1630.51</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>97830.7</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>97.8307</p></td><td style="text-align:right; width:85.89pt; " class="ce5"><p>195.6614</p></td></tr><tr class="ro3"><td style="text-align:right; width:111.66pt; " class="ce5"><p>191355</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>32768</p></td><td style="text-align:right; width:107.01pt; " class="ce5"><p>1594.62</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>47838.7</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>47.8387</p></td><td style="text-align:right; width:85.89pt; " class="ce5"><p>95.6774</p></td></tr><tr class="ro3"><td style="text-align:right; width:111.66pt; " class="ce5"><p>161033</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>16384</p></td><td style="text-align:right; width:107.01pt; " class="ce5"><p>1341.95</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>20129.2</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>20.1292</p></td><td style="text-align:right; width:85.89pt; " class="ce5"><p>40.2584</p></td></tr><tr class="ro3"><td style="text-align:right; width:111.66pt; " class="ce5"><p>118458</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>8192</p></td><td style="text-align:right; width:107.01pt; " class="ce5"><p>987.149</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>7403.61</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>7.40361</p></td><td style="text-align:right; width:85.89pt; " class="ce5"><p>14.80722</p></td></tr><tr class="ro3"><td style="text-align:right; width:111.66pt; " class="ce5"><p>101742</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>2048</p></td><td style="text-align:right; width:107.01pt; " class="ce5"><p>847.851</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>1589.72</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>1.58972</p></td><td style="text-align:right; width:85.89pt; " class="ce5"><p>3.17944</p></td></tr><tr class="ro3"><td style="text-align:right; width:111.66pt; " class="ce5"><p>100924</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>4096</p></td><td style="text-align:right; width:107.01pt; " class="ce5"><p>841.033</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>3153.88</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>3.15388</p></td><td style="text-align:right; width:85.89pt; " class="ce5"><p>6.30776</p></td></tr><tr class="ro3"><td style="text-align:right; width:111.66pt; " class="ce5"><p>100723</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>1024</p></td><td style="text-align:right; width:107.01pt; " class="ce5"><p>839.362</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>786.902</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>0.786902</p></td><td style="text-align:right; width:85.89pt; " class="ce5"><p>1.573804</p></td></tr></table>



<table border="0" cellspacing="0" cellpadding="0" class="ta1" width="100%"><colgroup><col width="150"/><col width="99"/><col width="205"/><col width="99"/><col width="99"/><col width="139"/></colgroup><tr class="ro1"><td colspan="3" style="text-align:left;width:97.26pt; " class="ce1"><p>LAppS-0.7.0-TLS, 96 clients, conn_weight=0.8, </p><p>Autofragmentatoin enabled, fragment_size=1392</p><p>(queue load preferenced)</p><p>2-Listeners, 4-workers, 4-echo service instances</p></td><td colspan="2" style="text-align:left;width:64.01pt; " class="ce1"><p>Throughput</p></td><td style="text-align:left;width:90.06pt; " class="ce1"><p>Total throughput</p></td></tr><tr class="ro2"><td style="text-align:left;width:97.26pt; " class="ce1"><p>Total roundtrips</p><p>Per second</p></td><td style="text-align:left;width:64.01pt; " class="ce6"><p>Payload size</p></td><td style="text-align:left;width:132.75pt; " class="ce1"><p>Roundtrips per</p><p>Seconds per client</p></td><td style="text-align:left;width:64.01pt; " class="ce1"><p>Mbit/s</p></td><td style="text-align:left;width:64.01pt; " class="ce1"><p>Gbit/s</p></td><td style="text-align:left;width:90.06pt; " class="ce1"><p>Gbit/s</p></td></tr><tr class="ro3"><td style="text-align:right; width:97.26pt; " class="ce5"><p>223539</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>65536</p></td><td style="text-align:right; width:132.75pt; " class="ce5"><p>2328.53</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>111770</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>111.77</p></td><td style="text-align:right; width:90.06pt; " class="ce5"><p>223.54</p></td></tr><tr class="ro3"><td style="text-align:right; width:97.26pt; " class="ce5"><p>213886</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>32768</p></td><td style="text-align:right; width:132.75pt; " class="ce5"><p>2227.98</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>53471.5</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>53.4715</p></td><td style="text-align:right; width:90.06pt; " class="ce5"><p>106.943</p></td></tr><tr class="ro3"><td style="text-align:right; width:97.26pt; " class="ce5"><p>199582</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>16384</p></td><td style="text-align:right; width:132.75pt; " class="ce5"><p>2078.98</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>24947.8</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>24.9478</p></td><td style="text-align:right; width:90.06pt; " class="ce5"><p>49.8956</p></td></tr><tr class="ro3"><td style="text-align:right; width:97.26pt; " class="ce5"><p>188151</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>8192</p></td><td style="text-align:right; width:132.75pt; " class="ce5"><p>1959.9</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>11759.4</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>11.7594</p></td><td style="text-align:right; width:90.06pt; " class="ce5"><p>23.5188</p></td></tr><tr class="ro3"><td style="text-align:right; width:97.26pt; " class="ce5"><p>174634</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>131072</p></td><td style="text-align:right; width:132.75pt; " class="ce5"><p>1819.1</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>174634</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>174.634</p></td><td style="text-align:right; width:90.06pt; " class="ce5"><p>349.268</p></td></tr><tr class="ro3"><td style="text-align:right; width:97.26pt; " class="ce5"><p>157541</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>4096</p></td><td style="text-align:right; width:132.75pt; " class="ce5"><p>1641.05</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>4923.15</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>4.92315</p></td><td style="text-align:right; width:90.06pt; " class="ce5"><p>9.8463</p></td></tr><tr class="ro3"><td style="text-align:right; width:97.26pt; " class="ce5"><p>127378</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>262144</p></td><td style="text-align:right; width:132.75pt; " class="ce5"><p>1326.86</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>254757</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>254.757</p></td><td style="text-align:right; width:90.06pt; " class="ce5"><p>509.514</p></td></tr><tr class="ro3"><td style="text-align:right; width:97.26pt; " class="ce5"><p>103942</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>2048</p></td><td style="text-align:right; width:132.75pt; " class="ce5"><p>1082.73</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>1624.1</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>1.6241</p></td><td style="text-align:right; width:90.06pt; " class="ce5"><p>3.2482</p></td></tr><tr class="ro3"><td style="text-align:right; width:97.26pt; " class="ce5"><p>92046.4</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>1024</p></td><td style="text-align:right; width:132.75pt; " class="ce5"><p>958.816</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>719.112</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>0.719112</p></td><td style="text-align:right; width:90.06pt; " class="ce5"><p>1.438224</p></td></tr></table>



<table border="0" cellspacing="0" cellpadding="0" class="ta1" width="100%"><colgroup><col width="139"/><col width="99"/><col width="207"/><col width="99"/><col width="99"/><col width="139"/></colgroup><tr class="ro1"><td colspan="3" style="text-align:left;width:90.06pt; " class="ce1"><p>uWebSockets-TLS, 120 clients, single thread,</p><p>Not tunable</p></td><td colspan="2" style="text-align:left;width:64.01pt; " class="ce1"><p>Throughput</p></td><td style="text-align:left;width:90.06pt; " class="ce1"><p>Total throughput</p></td></tr><tr class="ro1"><td style="text-align:left;width:90.06pt; " class="ce1"><p>Total roundtrips</p><p> Per second</p></td><td style="text-align:left;width:64.01pt; " class="ce6"><p>Payload size</p></td><td style="text-align:left;width:134.31pt; " class="ce1"><p>Roundtrips per</p><p>Second per client</p></td><td style="text-align:left;width:64.01pt; " class="ce1"><p>Mbit/s</p></td><td style="text-align:left;width:64.01pt; " class="ce1"><p>Gbit/s</p></td><td style="text-align:left;width:90.06pt; " class="ce1"><p>Gbit/s</p></td></tr><tr class="ro2"><td style="text-align:right; width:90.06pt; " class="ce5"><p>94845.5</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>262144</p></td><td style="text-align:right; width:134.31pt; " class="ce5"><p>790.379</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>189691</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>189.691</p></td><td style="text-align:right; width:90.06pt; " class="ce5"><p>379.382</p></td></tr><tr class="ro2"><td style="text-align:right; width:90.06pt; " class="ce5"><p>89493.8</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>2048</p></td><td style="text-align:right; width:134.31pt; " class="ce5"><p>745.781</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>1398.34</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>1.39834</p></td><td style="text-align:right; width:90.06pt; " class="ce5"><p>2.79668</p></td></tr><tr class="ro2"><td style="text-align:right; width:90.06pt; " class="ce5"><p>89406.1</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>4096</p></td><td style="text-align:right; width:134.31pt; " class="ce5"><p>745.051</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>2793.94</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>2.79394</p></td><td style="text-align:right; width:90.06pt; " class="ce5"><p>5.58788</p></td></tr><tr class="ro2"><td style="text-align:right; width:90.06pt; " class="ce5"><p>89085.9</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>1024</p></td><td style="text-align:right; width:134.31pt; " class="ce5"><p>742.383</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>695.984</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>0.695984</p></td><td style="text-align:right; width:90.06pt; " class="ce5"><p>1.391968</p></td></tr><tr class="ro2"><td style="text-align:right; width:90.06pt; " class="ce5"><p>88828.2</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>131072</p></td><td style="text-align:right; width:134.31pt; " class="ce5"><p>740.235</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>88828.2</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>88.8282</p></td><td style="text-align:right; width:90.06pt; " class="ce5"><p>177.6564</p></td></tr><tr class="ro2"><td style="text-align:right; width:90.06pt; " class="ce5"><p>88717.6</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>32768</p></td><td style="text-align:right; width:134.31pt; " class="ce5"><p>739.313</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>22179.4</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>22.1794</p></td><td style="text-align:right; width:90.06pt; " class="ce5"><p>44.3588</p></td></tr><tr class="ro2"><td style="text-align:right; width:90.06pt; " class="ce5"><p>88693</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>16384</p></td><td style="text-align:right; width:134.31pt; " class="ce5"><p>739.108</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>11086.6</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>11.0866</p></td><td style="text-align:right; width:90.06pt; " class="ce5"><p>22.1732</p></td></tr><tr class="ro2"><td style="text-align:right; width:90.06pt; " class="ce5"><p>87739.1</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>8192</p></td><td style="text-align:right; width:134.31pt; " class="ce5"><p>731.159</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>5483.7</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>5.4837</p></td><td style="text-align:right; width:90.06pt; " class="ce5"><p>10.9674</p></td></tr><tr class="ro2"><td style="text-align:right; width:90.06pt; " class="ce5"><p>87685.7</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>65536</p></td><td style="text-align:right; width:134.31pt; " class="ce5"><p>730.714</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>43842.8</p></td><td style="text-align:right; width:64.01pt; " class="ce5"><p>43.8428</p></td><td style="text-align:right; width:90.06pt; " class="ce5"><p>87.6856</p></td></tr></table>



<table border="0" cellspacing="0" cellpadding="0" class="ta1"><colgroup><col width="139"/><col width="105"/><col width="245"/><col width="68"/><col width="77"/><col width="139"/></colgroup><tr class="ro1"><td colspan="3" style="text-align:left;width:90.06pt; " class="ce1"><p>UWebSockets-TLS, 51/(120) clients, multithreaded (8 threads),</p><p>Not tunable </p><p>(only 51 clients were able to start, </p><p>Other have had timed out on TLS handshake)</p></td><td colspan="2" style="text-align:left;width:44.19pt; " class="ce1"><p>Throughput</p></td><td style="text-align:left;width:90.06pt; " class="ce1"><p>Total throughput</p></td></tr><tr class="ro2"><td style="text-align:left;width:90.06pt; " class="ce1"><p>Total roundtrips</p><p> Per second</p></td><td style="text-align:left;width:67.89pt; " class="ce6"><p>Payload size</p></td><td style="text-align:left;width:159pt; " class="ce1"><p>Roundtrips per</p><p>Second per client</p></td><td style="text-align:left;width:44.19pt; " class="ce1"><p>Mbit/s</p></td><td style="text-align:left;width:49.89pt; " class="ce1"><p>Gbit/s</p></td><td style="text-align:left;width:90.06pt; " class="ce1"><p>Gbit/s</p></td></tr><tr class="ro3"><td style="text-align:right; width:90.06pt; " class="ce5"><p>198393</p></td><td style="text-align:right; width:67.89pt; " class="ce5"><p>65536</p></td><td style="text-align:right; width:159pt; " class="ce5"><p>3890.05</p></td><td style="text-align:right; width:44.19pt; " class="ce5"><p>99196.4</p></td><td style="text-align:right; width:49.89pt; " class="ce5"><p>99.1964</p></td><td style="text-align:right; width:90.06pt; " class="ce5"><p>198.3928</p></td></tr><tr class="ro3"><td style="text-align:right; width:90.06pt; " class="ce5"><p>193197</p></td><td style="text-align:right; width:67.89pt; " class="ce5"><p>32768</p></td><td style="text-align:right; width:159pt; " class="ce5"><p>3788.17</p></td><td style="text-align:right; width:44.19pt; " class="ce5"><p>48299.2</p></td><td style="text-align:right; width:49.89pt; " class="ce5"><p>48.2992</p></td><td style="text-align:right; width:90.06pt; " class="ce5"><p>96.5984</p></td></tr><tr class="ro3"><td style="text-align:right; width:90.06pt; " class="ce5"><p>191945</p></td><td style="text-align:right; width:67.89pt; " class="ce5"><p>16384</p></td><td style="text-align:right; width:159pt; " class="ce5"><p>3763.62</p></td><td style="text-align:right; width:44.19pt; " class="ce5"><p>23993.1</p></td><td style="text-align:right; width:49.89pt; " class="ce5"><p>23.9931</p></td><td style="text-align:right; width:90.06pt; " class="ce5"><p>47.9862</p></td></tr><tr class="ro3"><td style="text-align:right; width:90.06pt; " class="ce5"><p>191839</p></td><td style="text-align:right; width:67.89pt; " class="ce5"><p>8192</p></td><td style="text-align:right; width:159pt; " class="ce5"><p>3761.54</p></td><td style="text-align:right; width:44.19pt; " class="ce5"><p>11989.9</p></td><td style="text-align:right; width:49.89pt; " class="ce5"><p>11.9899</p></td><td style="text-align:right; width:90.06pt; " class="ce5"><p>23.9798</p></td></tr><tr class="ro3"><td style="text-align:right; width:90.06pt; " class="ce5"><p>190885</p></td><td style="text-align:right; width:67.89pt; " class="ce5"><p>2048</p></td><td style="text-align:right; width:159pt; " class="ce5"><p>3742.83</p></td><td style="text-align:right; width:44.19pt; " class="ce5"><p>2982.57</p></td><td style="text-align:right; width:49.89pt; " class="ce5"><p>2.98257</p></td><td style="text-align:right; width:90.06pt; " class="ce5"><p>5.96514</p></td></tr><tr class="ro3"><td style="text-align:right; width:90.06pt; " class="ce5"><p>189769</p></td><td style="text-align:right; width:67.89pt; " class="ce5"><p>4096</p></td><td style="text-align:right; width:159pt; " class="ce5"><p>3720.97</p></td><td style="text-align:right; width:44.19pt; " class="ce5"><p>5930.29</p></td><td style="text-align:right; width:49.89pt; " class="ce5"><p>5.93029</p></td><td style="text-align:right; width:90.06pt; " class="ce5"><p>11.86058</p></td></tr><tr class="ro3"><td style="text-align:right; width:90.06pt; " class="ce5"><p>169098</p></td><td style="text-align:right; width:67.89pt; " class="ce5"><p>131072</p></td><td style="text-align:right; width:159pt; " class="ce5"><p>3315.64</p></td><td style="text-align:right; width:44.19pt; " class="ce5"><p>169098</p></td><td style="text-align:right; width:49.89pt; " class="ce5"><p>169.098</p></td><td style="text-align:right; width:90.06pt; " class="ce5"><p>338.196</p></td></tr><tr class="ro3"><td style="text-align:right; width:90.06pt; " class="ce5"><p>100108</p></td><td style="text-align:right; width:67.89pt; " class="ce5"><p>1024</p></td><td style="text-align:right; width:159pt; " class="ce5"><p>1962.9</p></td><td style="text-align:right; width:44.19pt; " class="ce5"><p>782.091</p></td><td style="text-align:right; width:49.89pt; " class="ce5"><p>0.782091</p></td><td style="text-align:right; width:90.06pt; " class="ce5"><p>1.564182</p></td></tr><tr class="ro3"><td style="text-align:right; width:90.06pt; " class="ce5"><p>49205.9</p></td><td style="text-align:right; width:67.89pt; " class="ce5"><p>262144</p></td><td style="text-align:right; width:159pt; " class="ce5"><p>964.821</p></td><td style="text-align:right; width:44.19pt; " class="ce5"><p>98411.8</p></td><td style="text-align:right; width:49.89pt; " class="ce5"><p>98.4118</p></td><td style="text-align:right; width:90.06pt; " class="ce5"><p>196.8236</p></td></tr></table>


There is still a lot of work to do until LAppS 0.7.1 release, though 0.7.0 already runs pretty stable (the above linked autobahn-testsuite regression tests are updated for 0.7.0), and so far it is a fastest TLS WebSocket Server implementation.


**NOTE¹:** The results of this test will be very different if you test it not on a single machine but on several servers. The network latency will impact these results drastically. Please If you are able to do these tests on several servers with 40GbE interfaces, give me a note on how well/bad they were. I might help with the tunning of LAppS for your environment.

**NOTE²:** Testing vs nginx+openresty or websocketpp echo server does not make any sense because they were already almost a little less then two times slower then uWebSockets and with 120 clients more then twice slower then LAppS.

**NOTE³:** If you find any issue with the test itself or the results please give me a note, so I might correct them. I might be too excited after 40hrs of nonstop coding.
