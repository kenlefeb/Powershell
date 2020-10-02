using namespace System.Management.Automation
using namespace System.Management.Automation.Language
Register-ArgumentCompleter -Native -CommandName 'dapr' -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    $commandElements = $commandAst.CommandElements
    $command = @(
        'dapr'
        for ($i = 1; $i -lt $commandElements.Count; $i++) {
            $element = $commandElements[$i]
            if ($element -isnot [StringConstantExpressionAst] -or
                $element.StringConstantType -ne [StringConstantType]::BareWord -or
                $element.Value.StartsWith('-')) {
                break
            }
            $element.Value
        }
    ) -join ';'
    $completions = @(switch ($command) {
        'dapr' {
            [CompletionResult]::new('completion', 'completion', [CompletionResultType]::ParameterValue, 'Generates shell completion scripts')
            [CompletionResult]::new('components', 'components', [CompletionResultType]::ParameterValue, 'List all Dapr components')
            [CompletionResult]::new('configurations', 'configurations', [CompletionResultType]::ParameterValue, 'List all Dapr configurations')
            [CompletionResult]::new('dashboard', 'dashboard', [CompletionResultType]::ParameterValue, 'Start Dapr dashboard')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Help about any command')
            [CompletionResult]::new('init', 'init', [CompletionResultType]::ParameterValue, 'Setup dapr in Kubernetes or Standalone modes')
            [CompletionResult]::new('invoke', 'invoke', [CompletionResultType]::ParameterValue, 'Invokes a Dapr app with an optional payload (deprecated, use invokePost)')
            [CompletionResult]::new('invokeGet', 'invokeGet', [CompletionResultType]::ParameterValue, 'Issue HTTP GET to Dapr app')
            [CompletionResult]::new('invokePost', 'invokePost', [CompletionResultType]::ParameterValue, 'Issue HTTP POST to Dapr app with an optional payload')
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List all Dapr instances')
            [CompletionResult]::new('logs', 'logs', [CompletionResultType]::ParameterValue, 'Gets Dapr sidecar logs for an app in Kubernetes')
            [CompletionResult]::new('mtls', 'mtls', [CompletionResultType]::ParameterValue, 'Check if mTLS is enabled in a Kubernetes cluster')
            [CompletionResult]::new('publish', 'publish', [CompletionResultType]::ParameterValue, 'Publish an event to multiple consumers')
            [CompletionResult]::new('run', 'run', [CompletionResultType]::ParameterValue, 'Launches Dapr and (optionally) your app side by side')
            [CompletionResult]::new('status', 'status', [CompletionResultType]::ParameterValue, 'Shows the Dapr system services (control plane) health status.')
            [CompletionResult]::new('stop', 'stop', [CompletionResultType]::ParameterValue, 'Stops multiple running Dapr instances and their associated apps')
            [CompletionResult]::new('uninstall', 'uninstall', [CompletionResultType]::ParameterValue, 'Removes a Dapr installation')
            break
        }
        'dapr;completion' {
            [CompletionResult]::new('bash', 'bash', [CompletionResultType]::ParameterValue, 'Generates bash completion scripts')
            [CompletionResult]::new('powershell', 'powershell', [CompletionResultType]::ParameterValue, 'Generates powershell completion scripts')
            [CompletionResult]::new('zsh', 'zsh', [CompletionResultType]::ParameterValue, 'Generates zsh completion scripts')
            break
        }
        'dapr;completion;bash' {
            break
        }
        'dapr;completion;powershell' {
            [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'help for powershell')
            [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'help for powershell')
            break
        }
        'dapr;completion;zsh' {
            break
        }
        'dapr;components' {
            [CompletionResult]::new('-k', 'k', [CompletionResultType]::ParameterName, 'List all Dapr components in a k8s cluster')
            [CompletionResult]::new('--kubernetes', 'kubernetes', [CompletionResultType]::ParameterName, 'List all Dapr components in a k8s cluster')
            break
        }
        'dapr;configurations' {
            [CompletionResult]::new('-k', 'k', [CompletionResultType]::ParameterName, 'List all Dapr configurations in a k8s cluster')
            [CompletionResult]::new('--kubernetes', 'kubernetes', [CompletionResultType]::ParameterName, 'List all Dapr configurations in a k8s cluster')
            break
        }
        'dapr;dashboard' {
            [CompletionResult]::new('-k', 'k', [CompletionResultType]::ParameterName, 'Start Dapr dashboard in local browser')
            [CompletionResult]::new('--kubernetes', 'kubernetes', [CompletionResultType]::ParameterName, 'Start Dapr dashboard in local browser')
            [CompletionResult]::new('-n', 'n', [CompletionResultType]::ParameterName, 'The namespace where Dapr dashboard is running')
            [CompletionResult]::new('--namespace', 'namespace', [CompletionResultType]::ParameterName, 'The namespace where Dapr dashboard is running')
            [CompletionResult]::new('-p', 'p', [CompletionResultType]::ParameterName, 'The local port on which to serve dashboard')
            [CompletionResult]::new('--port', 'port', [CompletionResultType]::ParameterName, 'The local port on which to serve dashboard')
            [CompletionResult]::new('-v', 'v', [CompletionResultType]::ParameterName, 'Check Dapr dashboard version')
            [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Check Dapr dashboard version')
            break
        }
        'dapr;help' {
            break
        }
        'dapr;init' {
            [CompletionResult]::new('--enable-ha', 'enable-ha', [CompletionResultType]::ParameterName, 'Deploy Dapr in a highly available mode. Default: false')
            [CompletionResult]::new('--enable-mtls', 'enable-mtls', [CompletionResultType]::ParameterName, 'Enable mTLS in your cluster. Default: true')
            [CompletionResult]::new('-k', 'k', [CompletionResultType]::ParameterName, 'Deploy Dapr to a Kubernetes cluster')
            [CompletionResult]::new('--kubernetes', 'kubernetes', [CompletionResultType]::ParameterName, 'Deploy Dapr to a Kubernetes cluster')
            [CompletionResult]::new('-n', 'n', [CompletionResultType]::ParameterName, 'The Kubernetes namespace to install Dapr in')
            [CompletionResult]::new('--namespace', 'namespace', [CompletionResultType]::ParameterName, 'The Kubernetes namespace to install Dapr in')
            [CompletionResult]::new('--network', 'network', [CompletionResultType]::ParameterName, 'The Docker network on which to deploy the Dapr runtime')
            [CompletionResult]::new('--redis-host', 'redis-host', [CompletionResultType]::ParameterName, 'The host on which the Redis service resides')
            [CompletionResult]::new('--runtime-version', 'runtime-version', [CompletionResultType]::ParameterName, 'The version of the Dapr runtime to install. for example: v0.1.0')
            [CompletionResult]::new('-s', 's', [CompletionResultType]::ParameterName, 'Initialize dapr in self-hosted mode without placement, redis and zipkin containers.')
            [CompletionResult]::new('--slim', 'slim', [CompletionResultType]::ParameterName, 'Initialize dapr in self-hosted mode without placement, redis and zipkin containers.')
            break
        }
        'dapr;invoke' {
            [CompletionResult]::new('-a', 'a', [CompletionResultType]::ParameterName, 'the app id to invoke')
            [CompletionResult]::new('--app-id', 'app-id', [CompletionResultType]::ParameterName, 'the app id to invoke')
            [CompletionResult]::new('-m', 'm', [CompletionResultType]::ParameterName, 'the method to invoke')
            [CompletionResult]::new('--method', 'method', [CompletionResultType]::ParameterName, 'the method to invoke')
            [CompletionResult]::new('-p', 'p', [CompletionResultType]::ParameterName, '(optional) a json payload')
            [CompletionResult]::new('--payload', 'payload', [CompletionResultType]::ParameterName, '(optional) a json payload')
            break
        }
        'dapr;invokeGet' {
            [CompletionResult]::new('-a', 'a', [CompletionResultType]::ParameterName, 'the app id to invoke')
            [CompletionResult]::new('--app-id', 'app-id', [CompletionResultType]::ParameterName, 'the app id to invoke')
            [CompletionResult]::new('-m', 'm', [CompletionResultType]::ParameterName, 'the method to invoke')
            [CompletionResult]::new('--method', 'method', [CompletionResultType]::ParameterName, 'the method to invoke')
            break
        }
        'dapr;invokePost' {
            [CompletionResult]::new('-a', 'a', [CompletionResultType]::ParameterName, 'the app id to invoke')
            [CompletionResult]::new('--app-id', 'app-id', [CompletionResultType]::ParameterName, 'the app id to invoke')
            [CompletionResult]::new('-m', 'm', [CompletionResultType]::ParameterName, 'the method to invoke')
            [CompletionResult]::new('--method', 'method', [CompletionResultType]::ParameterName, 'the method to invoke')
            [CompletionResult]::new('-p', 'p', [CompletionResultType]::ParameterName, '(optional) a json payload')
            [CompletionResult]::new('--payload', 'payload', [CompletionResultType]::ParameterName, '(optional) a json payload')
            break
        }
        'dapr;list' {
            [CompletionResult]::new('-k', 'k', [CompletionResultType]::ParameterName, 'List all Dapr pods in a k8s cluster')
            [CompletionResult]::new('--kubernetes', 'kubernetes', [CompletionResultType]::ParameterName, 'List all Dapr pods in a k8s cluster')
            break
        }
        'dapr;logs' {
            [CompletionResult]::new('-a', 'a', [CompletionResultType]::ParameterName, 'The app id for which logs are needed')
            [CompletionResult]::new('--app-id', 'app-id', [CompletionResultType]::ParameterName, 'The app id for which logs are needed')
            [CompletionResult]::new('-k', 'k', [CompletionResultType]::ParameterName, 'only works with a Kubernetes cluster')
            [CompletionResult]::new('--kubernetes', 'kubernetes', [CompletionResultType]::ParameterName, 'only works with a Kubernetes cluster')
            [CompletionResult]::new('-n', 'n', [CompletionResultType]::ParameterName, '(optional) Kubernetes namespace in which your application is deployed. default value is ''default''')
            [CompletionResult]::new('--namespace', 'namespace', [CompletionResultType]::ParameterName, '(optional) Kubernetes namespace in which your application is deployed. default value is ''default''')
            [CompletionResult]::new('-p', 'p', [CompletionResultType]::ParameterName, '(optional) Name of the Pod. Use this in case you have multiple app instances (Pods)')
            [CompletionResult]::new('--pod-name', 'pod-name', [CompletionResultType]::ParameterName, '(optional) Name of the Pod. Use this in case you have multiple app instances (Pods)')
            break
        }
        'dapr;mtls' {
            [CompletionResult]::new('-k', 'k', [CompletionResultType]::ParameterName, 'Check if mTLS is enabled in a Kubernetes cluster')
            [CompletionResult]::new('--kubernetes', 'kubernetes', [CompletionResultType]::ParameterName, 'Check if mTLS is enabled in a Kubernetes cluster')
            [CompletionResult]::new('expiry', 'expiry', [CompletionResultType]::ParameterValue, 'Checks the expiry of the root certificate')
            [CompletionResult]::new('export', 'export', [CompletionResultType]::ParameterValue, 'Export the root CA, issuer cert and key from Kubernetes to local files')
            break
        }
        'dapr;mtls;expiry' {
            break
        }
        'dapr;mtls;export' {
            [CompletionResult]::new('-o', 'o', [CompletionResultType]::ParameterName, 'Output directory path to save the certs')
            [CompletionResult]::new('--out', 'out', [CompletionResultType]::ParameterName, 'Output directory path to save the certs')
            break
        }
        'dapr;publish' {
            [CompletionResult]::new('-d', 'd', [CompletionResultType]::ParameterName, '(optional) a json serialized string')
            [CompletionResult]::new('--data', 'data', [CompletionResultType]::ParameterName, '(optional) a json serialized string')
            [CompletionResult]::new('--pubsub', 'pubsub', [CompletionResultType]::ParameterName, 'name of the pub/sub component')
            [CompletionResult]::new('-t', 't', [CompletionResultType]::ParameterName, 'the topic the app is listening on')
            [CompletionResult]::new('--topic', 'topic', [CompletionResultType]::ParameterName, 'the topic the app is listening on')
            break
        }
        'dapr;run' {
            [CompletionResult]::new('-i', 'i', [CompletionResultType]::ParameterName, 'an id for your application, used for service discovery')
            [CompletionResult]::new('--app-id', 'app-id', [CompletionResultType]::ParameterName, 'an id for your application, used for service discovery')
            [CompletionResult]::new('-p', 'p', [CompletionResultType]::ParameterName, 'the port your application is listening on')
            [CompletionResult]::new('--app-port', 'app-port', [CompletionResultType]::ParameterName, 'the port your application is listening on')
            [CompletionResult]::new('-P', 'P', [CompletionResultType]::ParameterName, 'tells Dapr to use HTTP or gRPC to talk to the app. Default is http')
            [CompletionResult]::new('--app-protocol', 'app-protocol', [CompletionResultType]::ParameterName, 'tells Dapr to use HTTP or gRPC to talk to the app. Default is http')
            [CompletionResult]::new('-d', 'd', [CompletionResultType]::ParameterName, 'Path for components directory. Default is $HOME/.dapr/components or %USERPROFILE%\.dapr\components')
            [CompletionResult]::new('--components-path', 'components-path', [CompletionResultType]::ParameterName, 'Path for components directory. Default is $HOME/.dapr/components or %USERPROFILE%\.dapr\components')
            [CompletionResult]::new('-c', 'c', [CompletionResultType]::ParameterName, 'Dapr configuration file. Default is $HOME/.dapr/config.yaml or %USERPROFILE%\.dapr\config.yaml')
            [CompletionResult]::new('--config', 'config', [CompletionResultType]::ParameterName, 'Dapr configuration file. Default is $HOME/.dapr/config.yaml or %USERPROFILE%\.dapr\config.yaml')
            [CompletionResult]::new('-G', 'G', [CompletionResultType]::ParameterName, 'the gRPC port for Dapr to listen on')
            [CompletionResult]::new('--dapr-grpc-port', 'dapr-grpc-port', [CompletionResultType]::ParameterName, 'the gRPC port for Dapr to listen on')
            [CompletionResult]::new('-H', 'H', [CompletionResultType]::ParameterName, 'the HTTP port for Dapr to listen on')
            [CompletionResult]::new('--dapr-http-port', 'dapr-http-port', [CompletionResultType]::ParameterName, 'the HTTP port for Dapr to listen on')
            [CompletionResult]::new('--enable-profiling', 'enable-profiling', [CompletionResultType]::ParameterName, 'Enable pprof profiling via an HTTP endpoint')
            [CompletionResult]::new('--image', 'image', [CompletionResultType]::ParameterName, 'the image to build the code in. input is repository/image')
            [CompletionResult]::new('--log-level', 'log-level', [CompletionResultType]::ParameterName, 'Sets the log verbosity. Valid values are: debug, info, warn, error, fatal, or panic. Default is info')
            [CompletionResult]::new('--max-concurrency', 'max-concurrency', [CompletionResultType]::ParameterName, 'controls the concurrency level of the app. Default is unlimited')
            [CompletionResult]::new('--placement-host-address', 'placement-host-address', [CompletionResultType]::ParameterName, 'the host on which the placement service resides')
            [CompletionResult]::new('--profile-port', 'profile-port', [CompletionResultType]::ParameterName, 'the port for the profile server to listen on')
            break
        }
        'dapr;status' {
            [CompletionResult]::new('-k', 'k', [CompletionResultType]::ParameterName, 'only works with a Kubernetes cluster')
            [CompletionResult]::new('--kubernetes', 'kubernetes', [CompletionResultType]::ParameterName, 'only works with a Kubernetes cluster')
            break
        }
        'dapr;stop' {
            [CompletionResult]::new('--app-id', 'app-id', [CompletionResultType]::ParameterName, 'app id to stop (standalone mode)')
            break
        }
        'dapr;uninstall' {
            [CompletionResult]::new('--all', 'all', [CompletionResultType]::ParameterName, 'Removes .dapr directory, Redis, Placement and Zipkin containers')
            [CompletionResult]::new('-k', 'k', [CompletionResultType]::ParameterName, 'Uninstall Dapr from a Kubernetes cluster')
            [CompletionResult]::new('--kubernetes', 'kubernetes', [CompletionResultType]::ParameterName, 'Uninstall Dapr from a Kubernetes cluster')
            [CompletionResult]::new('-n', 'n', [CompletionResultType]::ParameterName, 'The namespace to uninstall Dapr from (Kubernetes mode only)')
            [CompletionResult]::new('--namespace', 'namespace', [CompletionResultType]::ParameterName, 'The namespace to uninstall Dapr from (Kubernetes mode only)')
            [CompletionResult]::new('--network', 'network', [CompletionResultType]::ParameterName, 'The Docker network from which to remove the Dapr runtime')
            break
        }
    })
    $completions.Where{ $_.CompletionText -like "$wordToComplete*" } |
        Sort-Object -Property ListItemText
}
