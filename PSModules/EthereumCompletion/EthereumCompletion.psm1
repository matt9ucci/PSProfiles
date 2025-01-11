function CR {
	param (
		[string]$CompletionText,
		[string]$ToolTip
	)

	New-Object System.Management.Automation.CompletionResult $CompletionText, $CompletionText, ParameterName, $ToolTip
}

Register-ArgumentCompleter -CommandName geth -Native -ScriptBlock {
	param ([string]$wordToComplete, $commandAst, $cursorPosition)

	# Version: 1.8.12-stable

	if ($wordToComplete.StartsWith('-')) {
		@(
			# ETHEREUM OPTIONS:
			CR --config     'TOML configuration file'
			CR --datadir    'Data directory for the databases and keystore'
			CR --ethstats   'Reporting URL of a ethstats service (nodename:secret@host:port)'
			CR --gcmode     'Blockchain garbage collection mode ("full", "archive") (default: "full")'
			CR --identity   'Custom node name'
			CR --keystore   'Directory for the keystore (default = inside the datadir)'
			CR --lightkdf   'Reduce key-derivation RAM & CPU usage at some expense of KDF strength'
			CR --lightpeers 'Maximum number of LES client peers (default: 100)'
			CR --lightserv  'Maximum percentage of time allowed for serving LES requests (0-90) (default: 0)'
			CR --networkid  'Network identifier (integer, 1=Frontier, 2=Morden (disused), 3=Ropsten, 4=Rinkeby) (default: 1)'
			CR --nousb      'Disables monitoring for and managing USB hardware wallets'
			CR --rinkeby    'Rinkeby network: pre-configured proof-of-authority test network'
			CR --syncmode   'Blockchain sync mode ("fast", "full", or "light")'
			CR --testnet    'Ropsten network: pre-configured proof-of-work test network'

			# DEVELOPER CHAIN OPTIONS:
			CR --dev        'Ephemeral proof-of-authority network with a pre-funded developer account, mining enabled'
			CR --dev.period 'Block period to use in developer mode (0 = mine only if transaction pending) (default: 0)'

			# ETHASH OPTIONS:
			CR --ethash.cachedir     'Directory to store the ethash verification caches (default = inside the datadir)'
			CR --ethash.cachesinmem  'Number of recent ethash caches to keep in memory (16MB each) (default: 2)'
			CR --ethash.cachesondisk 'Number of recent ethash caches to keep on disk (16MB each) (default: 3)'
			CR --ethash.dagdir       'Directory to store the ethash mining DAGs (default = inside home folder)'
			CR --ethash.dagsinmem    'Number of recent ethash mining DAGs to keep in memory (1+GB each) (default: 1)'
			CR --ethash.dagsondisk   'Number of recent ethash mining DAGs to keep on disk (1+GB each) (default: 2)'

			# TRANSACTION POOL OPTIONS:
			CR --txpool.accountqueue 'Maximum number of non-executable transaction slots permitted per account (default: 64)'
			CR --txpool.accountslots 'Minimum number of executable transaction slots guaranteed per account (default: 16)'
			CR --txpool.globalqueue  'Maximum number of non-executable transaction slots for all accounts (default: 1024)'
			CR --txpool.globalslots  'Maximum number of executable transaction slots for all accounts (default: 4096)'
			CR --txpool.journal      'Disk journal for local transaction to survive node restarts (default: "transactions.rlp")'
			CR --txpool.lifetime     'Maximum amount of time non-executable transaction are queued (default: 3h0m0s)'
			CR --txpool.nolocals     'Disables price exemptions for locally submitted transactions'
			CR --txpool.pricebump    'Price bump percentage to replace an already existing transaction (default: 10)'
			CR --txpool.pricelimit   'Minimum gas price limit to enforce for acceptance into the pool (default: 1)'
			CR --txpool.rejournal    'Time interval to regenerate the local transaction journal (default: 1h0m0s)'

			# PERFORMANCE TUNING OPTIONS:
			CR --cache           'Megabytes of memory allocated to internal caching (default: 1024)'
			CR --cache.database  'Percentage of cache memory allowance to use for database io (default: 75)'
			CR --cache.gc        'Percentage of cache memory allowance to use for trie pruning (default: 25)'
			CR --trie-cache-gens 'Number of trie node generations to keep in memory (default: 120)'

			# ACCOUNT OPTIONS:
			CR --password 'Password file to use for non-interactive password input'
			CR --unlock   'Comma separated list of accounts to unlock'

			# API AND CONSOLE OPTIONS:
			CR --exec          'Execute JavaScript statement'
			CR --ipcdisable    'Disable the IPC-RPC server'
			CR --ipcpath       'Filename for IPC socket/pipe within the datadir (explicit paths escape it)'
			CR --jspath        'JavaScript root path for loadScript (default: ".")'
			CR --preload       'Comma separated list of JavaScript files to preload into the console'
			CR --rpc           'Enable the HTTP-RPC server'
			CR --rpcaddr       'HTTP-RPC server listening interface (default: "localhost")'
			CR --rpcapi        'API''s offered over the HTTP-RPC interface'
			CR --rpccorsdomain 'Comma separated list of domains from which to accept cross origin requests (browser enforced)'
			CR --rpcport       'HTTP-RPC server listening port (default: 8545)'
			CR --rpcvhosts     'Comma separated list of virtual hostnames from which to accept requests (server enforced). Accepts ''*'' wildcard. (default: "localhost")'
			CR --ws            'Enable the WS-RPC server'
			CR --wsaddr        'WS-RPC server listening interface (default: "localhost")'
			CR --wsapi         'API''s offered over the WS-RPC interface'
			CR --wsorigins     'Origins from which to accept websockets requests'
			CR --wsport        'WS-RPC server listening port (default: 8546)'

			# NETWORKING OPTIONS:
			CR --bootnodes    'Comma separated enode URLs for P2P discovery bootstrap (set v4+v5 instead for light servers)'
			CR --bootnodesv4  'Comma separated enode URLs for P2P v4 discovery bootstrap (light server, full nodes)'
			CR --bootnodesv5  'Comma separated enode URLs for P2P v5 discovery bootstrap (light server, light nodes)'
			CR --maxpeers     'Maximum number of network peers (network disabled if set to 0) (default: 25)'
			CR --maxpendpeers 'Maximum number of pending connection attempts (defaults used if set to 0) (default: 0)'
			CR --nat          'NAT port mapping mechanism (any|none|upnp|pmp|extip:<IP>) (default: "any")'
			CR --netrestrict  'Restricts network communication to the given IP networks (CIDR masks)'
			CR --nodekey      'P2P node key file'
			CR --nodekeyhex   'P2P node key as hex (for testing)'
			CR --nodiscover   'Disables the peer discovery mechanism (manual peer addition)'
			CR --port         'Network listening port (default: 30303)'
			CR --v5disc       'Enables the experimental RLPx V5 (Topic Discovery) mechanism'

			# MINER OPTIONS:
			CR --etherbase      'Public address for block mining rewards (default = first account created) (default: "0")'
			CR --extradata      'Block extra data set by the miner (default = client version)'
			CR --gasprice       'Minimal gas price to accept for mining a transactions'
			CR --mine           'Enable mining'
			CR --minerthreads   'Number of CPU threads to use for mining (default: 4)'
			CR --targetgaslimit 'Target gas limit sets the artificial target gas floor for the blocks to mine (default: 4712388)'

			# GAS PRICE ORACLE OPTIONS:
			CR --gpoblocks     'Number of recent blocks to check for gas prices (default: 20)'
			CR --gpopercentile 'Suggested gas price is the given percentile of a set of recent transaction gas prices (default: 60)'

			# VIRTUAL MACHINE OPTIONS:
			CR --vmdebug 'Record information useful for VM and contract debugging'

			# LOGGING AND DEBUGGING OPTIONS:
			CR --backtrace        'Request a stack trace at a specific logging statement (e.g. "block.go:271")'
			CR --blockprofilerate 'Turn on block profiling with the given rate (default: 0)'
			CR --cpuprofile       'Write CPU profile to the given file'
			CR --debug            'Prepends log messages with call-site location (file and line number)'
			CR --fakepow          'Disables proof-of-work verification'
			CR --memprofilerate   'Turn on memory profiling with the given rate (default: 524288)'
			CR --nocompaction     'Disables db compaction after import'
			CR --pprof            'Enable the pprof HTTP server'
			CR --pprofaddr        'pprof HTTP server listening interface (default: "127.0.0.1")'
			CR --pprofport        'pprof HTTP server listening port (default: 6060)'
			CR --trace            'Write execution trace to the given file'
			CR --verbosity        'Logging verbosity: 0=silent, 1=error, 2=warn, 3=info, 4=debug, 5=detail (default: 3)'
			CR --vmodule          'Per-module verbosity: comma-separated list of <pattern>=<level> (e.g. eth/*=5,p2p=4)'

			# METRICS AND STATS OPTIONS:
			CR --metrics                   'Enable metrics collection and reporting'
			CR --metrics.influxdb          'Enable metrics export/push to an external InfluxDB database'
			CR --metrics.influxdb.endpoint 'InfluxDB API endpoint to report metrics to (default: "http://localhost:8086")'
			CR --metrics.influxdb.database 'InfluxDB database name to push reported metrics to (default: "geth")'
			CR --metrics.influxdb.username 'Username to authorize access to the database (default: "test")'
			CR --metrics.influxdb.password 'Password to authorize access to the database (default: "test")'
			CR --metrics.influxdb.host.tag 'InfluxDB host tag attached to all measurements (default: "localhost")'

			# WHISPER (EXPERIMENTAL) OPTIONS:
			CR --shh                'Enable Whisper'
			CR --shh.maxmessagesize 'Max message size accepted (default: 1048576)'
			CR --shh.pow            'Minimum POW accepted (default: 0.2)'

			# DEPRECATED OPTIONS:
			CR --fast  'Enable fast syncing through state downloads (replaced by --syncmode)'
			CR --light 'Enable light client mode (replaced by --syncmode)'

			# MISC OPTIONS:
			CR --help 'show help'
			CR '-h'   'show help'

		) | ? CompletionText -Like "$wordToComplete*"
	} elseif ($commandAst.CommandElements[-1].Extent.Text -eq '--rpcapi') {
		return ('eth', 'shh', 'web3', 'admin', 'db', 'debug', 'miner', 'personal', 'txpool') -join ','
	} else {
		@(
			CR 'account'          'Manage accounts'
			CR 'attach'           'Start an interactive JavaScript environment (connect to node)'
			CR 'bug'              'opens a window to report a bug on the geth repo'
			CR 'console'          'Start an interactive JavaScript environment'
			CR 'copydb'           'Create a local chain from a target chaindata folder'
			CR 'dump'             'Dump a specific block from storage'
			CR 'dumpconfig'       'Show configuration values'
			CR 'export-preimages' 'Export the preimage database into an RLP stream'
			CR 'export'           'Export blockchain into file'
			CR 'import-preimages' 'Import the preimage database from an RLP stream'
			CR 'import'           'Import a blockchain file'
			CR 'init'             'Bootstrap and initialize a new genesis block'
			CR 'js'               'Execute the specified JavaScript files'
			CR 'makecache'        'Generate ethash verification cache (for testing)'
			CR 'makedag'          'Generate ethash mining DAG (for testing)'
			CR 'monitor'          'Monitor and visualize node metrics'
			CR 'removedb'         'Remove blockchain and state databases'
			CR 'wallet'           'Manage Ethereum presale wallets'

			CR 'license'          'Display license information'
			CR 'version'          'Print version numbers'
			CR 'help'             'Shows a list of commands or help for one command'
			CR 'h'                'Shows a list of commands or help for one command'
		) | ? CompletionText -Like "$wordToComplete*"
	}
}

Register-ArgumentCompleter -CommandName solc -Native -ScriptBlock {
	param ([string]$wordToComplete, $commandAst, $cursorPosition)

	if ($wordToComplete.StartsWith('-')) {
		@(
			CR --abi              'ABI specification of the contracts.'
			CR --asm              'EVM assembly of the contracts.'
			CR --asm-json         'EVM assembly of the contracts in JSON format.'
			CR --ast              'AST of all source files.'
			CR --ast-compact-json 'AST of all source files in a compact JSON format.'
			CR --ast-json         'AST of all source files in JSON format.'
			CR --bin              'Binary of the contracts in hex.'
			CR --bin-runtime      'Binary of the runtime part of the contracts in hex.'
			CR --clone-bin        'Binary of the clone contracts in hex.'
			CR --devdoc           'Natspec developer documentation of all contracts.'
			CR --formal           'Translated source suitable for formal analysis. (Deprecated)'
			CR --hashes           'Function signature hashes of the contracts.'
			CR --metadata         'Combined Metadata JSON whose Swarm hash is stored on-chain.'
			CR --opcodes          'Opcodes of the contracts.'
			CR --userdoc          'Natspec user documentation of all contracts.'

			CR --allow-paths 'Allow a given path for imports. A list of paths can be supplied by separating them with a comma.'
			CR --assemble 'Switch to assembly mode, ignoring all options except --machine and assumes input is assembly.'
			CR --combined-json 'Output a single json document containing the specified information.'
			CR --evm-version 'Select desired EVM version. Either homestead, tangerineWhistle, spuriousDragon, byzantium (default) or constantinople.'
			CR --gas 'Print an estimate of the maximal gas usage for each function.'
			CR --ignore-missing 'Ignore missing files.'
			CR --julia 'Switch to JULIA mode, ignoring all options except --machine and assumes input is JULIA.'
			CR --libraries 'Direct string or file containing library addresses. Syntax: <libraryName>: <address> [, or whitespace] ... Address is interpreted as a hex string optionally prefixed by 0x.'
			CR --link 'Switch to linker mode, ignoring all options apart from --libraries and modify binaries in place.'
			CR --machine 'Target machine in assembly or JULIA mode.'
			CR --metadata-literal 'Store referenced sources are literal data in the metadata output.'
			CR --optimize 'Enable bytecode optimizer.'
			CR --optimize-runs 'Set for how many contract runs to optimize.Lower values will optimize more for initial deployment cost, higher values will optimize more for high-frequency usage.'
			CR --output-dir 'If given, creates one file per component and contract/file at the specified directory.'
			CR '-o' 'If given, creates one file per component and contract/file at the specified directory.'
			CR --overwrite 'Overwrite existing files (used together with -o).'
			CR --pretty-json 'Output JSON in pretty format. Currently it only works with the combined JSON output.'
			CR --standard-json 'Switch to Standard JSON input / output mode, ignoring all options. It reads from standard input and provides the result on the standard output.'
			CR --strict-assembly 'Switch to strict assembly mode, ignoring all options except --machine and assumes input is strict assembly.'

			CR --license 'Show licensing information and exit.'
			CR --version 'Show version and exit.'
			CR --help 'Show help message and exit.'
		) | ? CompletionText -Like "$wordToComplete*"
		return
	}

	[string]$option = ''
	foreach ($ce in $commandAst.CommandElements) {
		[string]$text = $ce.Extent.Text
		if ($text.StartsWith('-')) {
			$option = $text
		} elseif ($wordToComplete -ne ($text -split ',')[-1]) {
			$option = ''
		}
	}

	[string[]]$values = ''
	switch ($option) {
		'--evm-version' {
			$values = 'homestead', 'tangerineWhistle', 'spuriousDragon', 'byzantium', 'constantinople'
		}
		'--combined-json' {
			$values = 'abi', 'asm', 'ast', 'bin', 'bin-runtime', 'clone-bin', 'compact-format', 'devdoc', 'hashes', 'interface', 'metadata', 'opcodes', 'srcmap', 'srcmap-runtime', 'userdoc'
		}
		'--machine' {
			$values = 'evm', 'evm15', 'ewasm'
		}
		default {
			return
		}
	}

	$result = $values -Like "$wordToComplete*"
	if ($result.Count -eq 0) {
		$wordToComplete
	} else {
		$result
	}
}

Export-ModuleMember -Function @()
