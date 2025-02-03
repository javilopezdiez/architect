    def init_poolmanager(self, connections, maxsize, block=False):
        ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS_CLIENT)
        ssl_context.set_ciphers('DEFAULT:@SECLEVEL=1')

        # ADDED, so that we fix
        # https://github.com/dlenski/gp-saml-gui/issues/83
        ssl_context.check_hostname = False

        ssl_context.options |= 1<<2  # OP_LEGACY_SERVER_CONNECT

        if not self.verify:
            ssl_context.check_hostname = False
            ssl_context.verify_mode = ssl.CERT_NONE

        if hasattr(ssl_context, "keylog_filename"):
            sslkeylogfile = environ.get("SSLKEYLOGFILE")
            if sslkeylogfile:
                ssl_context.keylog_filename = sslkeylogfile

        self.poolmanager = urllib3.PoolManager(
                num_pools=connections,
                maxsize=maxsize,
                block=block,
                ssl_context=ssl_context)

