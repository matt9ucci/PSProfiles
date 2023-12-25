function Save-BitcoinCore {
	$params = @{
		Uri = "https://bitcoincore.org/bin/bitcoin-core-25.0/bitcoin-25.0-win64.zip"
		OutFile = "./bitcoin-25.0-win64.zip"
		Verbose = $true
	}
	Invoke-WebRequest @params
}

Register-ArgumentCompleter -Native -CommandName bitcoin-cli, btcc -ScriptBlock {
	param ([string]$wordToComplete, $commandAst, $cursorPosition)

	function CR ([string]$CompletionText, [string]$ToolTip = $CompletionText) {
		New-Object System.Management.Automation.CompletionResult $CompletionText, $CompletionText, ParameterName, $ToolTip
	}

	if ($wordToComplete.StartsWith('-')) {
		@(
			CR '-conf' 'Specify configuration file. Relative paths will be prefixed by datadir location. (default: bitcoin.conf)'
			CR '-datadir' 'Specify data directory'
			CR '-getinfo' 'Get general information from the remote server. Note that unlike server-side RPC calls, the results of -getinfo is the result of multiple non-atomic requests. Some entries in the result may represent results from different states (e.g. wallet balance may be as of a different block from the chain state reported)'
			CR '-named' 'Pass named instead of positional arguments (default: false)'
			CR '-rpcclienttimeout' 'Timeout in seconds during HTTP requests, or 0 for no timeout. (default: 900)'
			CR '-rpcconnect' 'Send commands to node running on <ip> (default: 127.0.0.1)'
			CR '-rpccookiefile' 'Location of the auth cookie. Relative paths will be prefixed by a net-specific datadir location. (default: data dir)'
			CR '-rpcpassword' 'Password for JSON-RPC connections'
			CR '-rpcport' 'Connect to JSON-RPC on <port> (default: 8332 or testnet: 18332)'
			CR '-rpcuser' 'Username for JSON-RPC connections'
			CR '-rpcwait' 'Wait for RPC server to start'
			CR '-rpcwallet' 'Send RPC for non-default wallet on RPC server (needs to exactly match corresponding -wallet option passed to bitcoind)'
			CR '-stdin' 'Read extra arguments from standard input, one per line until EOF/Ctrl-D (recommended for sensitive information such as passphrases). When combined with -stdinrpcpass, the first line from standard input is used for the RPC password.'
			CR '-stdinrpcpass' 'Read RPC password from standard input as a single line. When combined with -stdin, the first line from standard input is used for the RPC password.'
			CR '-regtest'
			CR '-testnet' 'Use the test chain'
			CR '-version' 'Print version and exit'
			CR '-?' 'This help message'
		) | ? CompletionText -Like "$wordToComplete*"
	} else {
		@(
			CR 'abandontransaction'
			CR 'abortrescan'
			CR 'addmultisigaddress'
			CR 'addnode'
			CR 'backupwallet'
			CR 'bumpfee'
			CR 'clearbanned'
			CR 'combinepsbt'
			CR 'combinerawtransaction'
			CR 'converttopsbt'
			CR 'createmultisig'
			CR 'createpsbt'
			CR 'createrawtransaction'
			CR 'createwallet'
			CR 'decodepsbt'
			CR 'decoderawtransaction'
			CR 'decodescript'
			CR 'disconnectnode'
			CR 'dumpprivkey'
			CR 'dumpwallet'
			CR 'encryptwallet'
			CR 'estimatesmartfee'
			CR 'finalizepsbt'
			CR 'fundrawtransaction'
			CR 'generate'
			CR 'generatetoaddress'
			CR 'getaccount'
			CR 'getaccountaddress'
			CR 'getaddednodeinfo'
			CR 'getaddressbyaccount'
			CR 'getaddressesbylabel'
			CR 'getaddressinfo'
			CR 'getbalance'
			CR 'getbestblockhash'
			CR 'getblock'
			CR 'getblockchaininfo'
			CR 'getblockcount'
			CR 'getblockhash'
			CR 'getblockheader'
			CR 'getblockstats'
			CR 'getblocktemplate'
			CR 'getchaintips'
			CR 'getchaintxstats'
			CR 'getconnectioncount'
			CR 'getdifficulty'
			CR 'getmemoryinfo'
			CR 'getmempoolancestors'
			CR 'getmempooldescendants'
			CR 'getmempoolentry'
			CR 'getmempoolinfo'
			CR 'getmininginfo'
			CR 'getnettotals'
			CR 'getnetworkhashps'
			CR 'getnetworkinfo'
			CR 'getnewaddress'
			CR 'getpeerinfo'
			CR 'getrawchangeaddress'
			CR 'getrawmempool'
			CR 'getrawtransaction'
			CR 'getreceivedbyaccount'
			CR 'getreceivedbyaddress'
			CR 'gettransaction'
			CR 'gettxout'
			CR 'gettxoutproof'
			CR 'gettxoutsetinfo'
			CR 'getunconfirmedbalance'
			CR 'getwalletinfo'
			CR 'getzmqnotifications'
			CR 'help'
			CR 'importaddress'
			CR 'importmulti'
			CR 'importprivkey'
			CR 'importprunedfunds'
			CR 'importpubkey'
			CR 'importwallet'
			CR 'keypoolrefill'
			CR 'listaccounts'
			CR 'listaddressgroupings'
			CR 'listbanned'
			CR 'listlabels'
			CR 'listlockunspent'
			CR 'listreceivedbyaccount'
			CR 'listreceivedbyaddress'
			CR 'listsinceblock'
			CR 'listtransactions'
			CR 'listunspent'
			CR 'listwallets'
			CR 'loadwallet'
			CR 'lockunspent'
			CR 'logging'
			CR 'move'
			CR 'ping'
			CR 'preciousblock'
			CR 'prioritisetransaction'
			CR 'pruneblockchain'
			CR 'removeprunedfunds'
			CR 'rescanblockchain'
			CR 'savemempool'
			CR 'scantxoutset'
			CR 'sendfrom'
			CR 'sendmany'
			CR 'sendrawtransaction'
			CR 'sendtoaddress'
			CR 'setaccount'
			CR 'setban'
			CR 'sethdseed'
			CR 'setnetworkactive'
			CR 'settxfee'
			CR 'signmessage'
			CR 'signmessagewithprivkey'
			CR 'signrawtransaction'
			CR 'signrawtransactionwithkey'
			CR 'signrawtransactionwithwallet'
			CR 'stop'
			CR 'submitblock'
			CR 'testmempoolaccept'
			CR 'unloadwallet'
			CR 'uptime'
			CR 'validateaddress'
			CR 'verifychain'
			CR 'verifymessage'
			CR 'verifytxoutproof'
			CR 'walletcreatefundedpsbt'
			CR 'walletlock'
			CR 'walletpassphrase'
			CR 'walletpassphrasechange'
			CR 'walletprocesspsbt'
		) | ? CompletionText -Like "$wordToComplete*"
	}
}

function Get-BlockTimespan {
	param (
		[ulong]
		$BlockCount
	)

	$m = $BlockCount * 10
	[timespan]::FromMinutes($m)
}

Set-Alias btcc bitcoin-cli
