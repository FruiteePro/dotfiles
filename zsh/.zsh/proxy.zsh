# ~/.zsh/proxy.zsh
# =====================================================
#          Proxy Helper Function
# =====================================================
# Usage:
#   proxy on   - Turn on the proxy
#   proxy off  - Turn off the proxy
#   proxy status - Check the current proxy status
# =====================================================
function proxy() {
    # --- Your Proxy Settings ---
    local http_host="127.0.0.1"
    local http_port="7897"
    local socks_port="7897"
    # --------------------------

    local http_proxy_url="http://${http_host}:${http_port}"
    local socks_proxy_url="socks5://${http_host}:${socks_port}"

    local cmd=${1:l}

    if [ "$cmd" = "on" ]; then
        export http_proxy="$http_proxy_url"
        export https_proxy="$http_proxy_url"
        export all_proxy="$socks_proxy_url"
        export no_proxy="localhost,127.0.0.1,::1"

        echo "✅ Proxy has been enabled."
        echo "   - http_proxy:  $http_proxy"
        echo "   - https_proxy: $https_proxy"
        echo "   - all_proxy:   $all_proxy"

    elif [ "$cmd" = "off" ]; then
        unset http_proxy
        unset https_proxy
        unset all_proxy
        unset no_proxy
        echo "❌ Proxy has been disabled."

    elif [ "$cmd" = "status" ]; then
        if [ -n "$http_proxy" ] || [ -n "$https_proxy" ]; then
            echo "✅ Proxy is ON."
            echo "   - http_proxy:  $http_proxy"
            echo "   - https_proxy: $https_proxy"
            echo "   - all_proxy:   $all_proxy"
        else
            echo "❌ Proxy is OFF."
        fi
    else
        echo "Usage: proxy [on|off|status]"
    fi
}

