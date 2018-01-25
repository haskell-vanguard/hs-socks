module Network.Socks5.Lowlevel
    ( resolveToSockAddr
    , socksListen
    -- * lowlevel types
    , module Network.Socks5.Wire
    , module Network.Socks5.Command
    ) where

import Network.Socket
import Network.Socks5.Command
import Network.Socks5.Wire
import Network.Socks5.Types
import qualified Data.ByteString.Char8 as BC

resolveToSockAddr :: SocksAddress -> IO SockAddr
resolveToSockAddr (SocksAddress sockHostAddr port) =
    case sockHostAddr of
        SocksAddrIPV4 ha       -> return $ SockAddrInet port ha
        SocksAddrIPV6 ha6      -> return $ SockAddrInet6 port 0 ha6 0
        SocksAddrDomainName bs -> do addr:_ <- getAddrInfo Nothing (Just $ BC.unpack bs) (Just $ show port)
                                     return $ addrAddress addr

socksListen :: Socket -> IO SocksRequest
socksListen sock = do
    hello <- waitSerialized sock
    case getSocksHelloMethods hello of
        _ -> do sendSerialized sock (SocksHelloResponse SocksMethodNone)
                waitSerialized sock
