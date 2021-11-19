pws_secrets:
  mail_relay:
    host: smtp.example.com
    port: 587
    username: test@example.com
    password: testpassword
  mail_marinakopf:
    host: smtp.example.com
    port: 465
    secure: ssl
    username: test@example.com
    password: testpassword
    from: mail
    from_domain: example.com
  db_password: test-password
  graylog:
    admin_sha2: 8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918
    secret: somepasswordpepper
  crashplan:
    vnc_password: test-password
  telegram_notification_bot:
    token: test-token
    chat_id: 1024
  photoprism:
    password: testpassword

  # Local cert for testing, signed for *.local.pws
  ssl_pws_local:
    crt: |
        -----BEGIN CERTIFICATE-----
        MIIDbjCCAlagAwIBAgIUSVcpR9CPW/rFfxy8axyPaS1CALQwDQYJKoZIhvcNAQEL
        BQAwWjELMAkGA1UEBhMCREUxCzAJBgNVBAgMAkJXMREwDwYDVQQKDAhQZXRyby53
        czEMMAoGA1UEAwwDcHdzMR0wGwYJKoZIhvcNAQkBFg5wZXRyb0BwZXRyby53czAe
        Fw0yMDA3MjQxMzMwMDhaFw0zNDA0MDIxMzMwMDhaMEkxCzAJBgNVBAYTAlJVMQww
        CgYDVQQIDANTcGIxGTAXBgNVBAcMEFNhaW50LVBldGVyc2J1cmcxETAPBgNVBAsM
        CHBldHJvLXdzMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtb1mWbni
        GfBQud5Prr1z19CcKIZ0JTqdw8bxwMUOGMRAkvmdIbowY8tQzuNCuh5JIzLaXlpW
        sW4x4/zIPxshiWxeC+nnVSn0Uo3QFxI2RAe2bJoTYLcyAQkJm/4BXeLeORm+eJKL
        FqSxIERcTvq7MGEve5HVU8f7VULawg/2fiiAFkcVKwq7MqoSxAnlzt9/Gq+3Q1HK
        4dUX6vcvnB/tOFDq2ZFAp9igzQZLyGUhWzCH/RgWoRg+/earDh8Z4v/I7LZK49Rh
        fMvb1cGWAQF2VOevJar7dX6TQbNP+f29FHoD7VR0fCjLiEULvKCbg7uHazzRVqXc
        sv1xZ3E/NFNEwQIDAQABoz0wOzAJBgNVHRMEAjAAMAsGA1UdDwQEAwIF4DAhBgNV
        HREEGjAYggsqLmxvY2FsLnB3c4IJbG9jYWwucHdzMA0GCSqGSIb3DQEBCwUAA4IB
        AQAjqWkWaukWtrFOd5l50bgJnfAtsp57i68aRgX9RduFMAWeEXjm67OF4rLhr5jl
        tYcMyCaxRZL5pgLIJjZUOrFYLOc9+nVeoTronMXXgfgDtP+I3bQeGbKDSYuEUcxc
        dwtsMhFz8j6sWcUyAEJSqEBEGln+1LGtJ7fFMY5OrJSNT88RSZ/MGi9nfUiesXJb
        wPY3q/WYIF0/ClafmURHfm6RI/4LJpk9tbrGJPMFrDuFd4ZrEa1TXtXfmgBsl7/A
        qYs5lgfSFoH9q7G11729zkR7UTRwCdZzEpz5OUVONPl8uXGoDY6y1mns15D7/k25
        hMPKXrLcZ5l4cVNeElJWuCoC
        -----END CERTIFICATE-----
    key: |
        -----BEGIN RSA PRIVATE KEY-----
        MIIEogIBAAKCAQEAtb1mWbniGfBQud5Prr1z19CcKIZ0JTqdw8bxwMUOGMRAkvmd
        IbowY8tQzuNCuh5JIzLaXlpWsW4x4/zIPxshiWxeC+nnVSn0Uo3QFxI2RAe2bJoT
        YLcyAQkJm/4BXeLeORm+eJKLFqSxIERcTvq7MGEve5HVU8f7VULawg/2fiiAFkcV
        Kwq7MqoSxAnlzt9/Gq+3Q1HK4dUX6vcvnB/tOFDq2ZFAp9igzQZLyGUhWzCH/RgW
        oRg+/earDh8Z4v/I7LZK49RhfMvb1cGWAQF2VOevJar7dX6TQbNP+f29FHoD7VR0
        fCjLiEULvKCbg7uHazzRVqXcsv1xZ3E/NFNEwQIDAQABAoIBAHNDbU+I6hKjbL+F
        dKoRtA/zWacGJ1GZTIfnfFpTYC5rAb11nKfQa3JPd6/PSPm7zY0Kap6e0w7zIadE
        IkiLz4hV94u8zKAh3LgjAxAu18Xr0lIsog+cAJXRgoux3HIMOf6jCj90ScyRpVke
        oiDhOqljafcINfFOC2Q244FjGGVH/pwbfDCSHftJFuYWl6Zkk307evepG281EZUr
        JrZV/DszD6WVMVqoL4F+DeY62OHnk5puHlUEUfnZTP/A7gfjTAra7XkDmyGDmsEg
        QlK4l6VyGOr0NoF8Kii8DA1RoxkLYa9jK3PHMFa8AtB3V9FfTn4WlE3rlErLzGdN
        uj4AvfUCgYEA4YvicBdyqu1XvnwbwzPHe7w1apaIfe6D6vm1J1Yvp5tFtyzQq9IJ
        gfp3bcctWeWI9B6aSCvBkkEs1kv3fD0SiAVZ3IaWq3/vDixgez3SbKyqceK3T4T4
        Xinu3DRNqxl8SohtP6xrt1W7UUxJQW0Y+zdFN4D6dIl7qmGUre+zj88CgYEAzkdS
        HEjALIUPmebLDH65UzKIg2jL3koNNLBi8/t74y9UyOK3+kTm/FJUbyDQtQVfaL5Z
        Y71zW34P72um0c3N8QOZsvhRmPWiKV8ImkqYviwBzWzzDx7H0+9Oth8FLeUl81I8
        bHCtG5ndqP5XwbQYjKAjRBkP9spke96rv2UJ9m8CgYAQgIaZwu1t2h2wXy480v4G
        bJfP66Gi7R+Twp9heGnWLoMkStAdsill7ChuzMLhr+ycR9zr6N+pzsD0EOzTlzhS
        4WlYvDQr6hlYhSCuA7DwqJVz7a2R0N3HLfQ/Akioex3f6ilsHjZnXItvAFDfy5an
        UrzqubIZcrGsnqUdMMuHewKBgECAgsd/ZEBHl1pLleChW7gNTCyzP1SSGVEJetfK
        IrImob9zTY4/r27lG6voOfrw5CWvp+oNWp4YbEk0g2SFk0kzFAOnrHRFEuEW62y7
        uMl2n1WqJNLskBXQde9zAb6ZMeXFKEnMbgT8dxiZ970FYMvQY1au85P7M7KcLV5a
        7OOXAoGAN8M6VYBF7HZwy082ZwIsFwa4ZS9+IiGG93OvkkjEmpiAeJCbvMVKaaxp
        Tlm+ixBclW3XjfJsNiyaCdtVV5Y1d59ypu+OoTTDeHupCnYlXPrjtlYNjBU4fs8f
        5KISKscynKdvOZ1TMXWU+rUOGzumT6HfJML6qdBHaGo7PmTaock=
        -----END RSA PRIVATE KEY-----
  ssh_salt_private:
    public: ''
    private: ''
  ssh_cmk_private:
    public:
      enc: ''
      key: ''
    private: ''
