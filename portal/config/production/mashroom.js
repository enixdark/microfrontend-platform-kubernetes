
const {
    REDIS_HOST,
    REDIS_PORT,
    RABBITMQ_HOST,
    RABBITMQ_PORT,
    RABBITMQ_USER,
    RABBITMQ_PASSWORD,
    SHOW_ENV_AND_VERSIONS,
} = process.env;

const DATA_FOLDER = '/var/shared/mashroom-data';

module.exports = {
    name: 'Mashroom Portal Quickstart',
    port: 5050,
    pluginPackageFolders: [
        {
            'path': '../../node_modules/@mashroom',
        },
    ],
    ignorePlugins: [
    ],
    indexPage: '/portal',
    plugins: {
        'Mashroom Portal WebApp': {
            adminApp: 'Mashroom Portal Admin App',
            defaultTheme: 'Mashroom Portal Default Theme',
            warnBeforeAuthenticationExpiresSec: 120
        },
        "Mashroom Portal Default Theme": {
            showEnvAndVersions: SHOW_ENV_AND_VERSIONS === "true" || SHOW_ENV_AND_VERSIONS === true,
        },
        'Mashroom Session Middleware': {
            provider: 'Mashroom Session Redis Provider',
            session: {
                cookie: {
                    maxAge: 3600000
                }
            }
        },
        'Mashroom Session Redis Provider': {
            redisOptions: {
                host: REDIS_HOST,
                port: REDIS_PORT,
                keyPrefix: 'mashroom-portal:',
            },
        },
        'Mashroom Security Services': {
            provider: 'Mashroom Security Simple Provider',
            acl: './acl.json',
            loginPage: '/login'
        },
        'Mashroom Security Simple Provider': {
            users: './users.json',
            authenticationTimeoutSec: 1200
        },
        'Mashroom Helmet Middleware': {

        },
        'Mashroom Storage Services': {
            provider: 'Mashroom Storage Filestore Provider'
        },
        'Mashroom Storage Filestore Provider': {
            dataFolder: DATA_FOLDER
        },
        'Mashroom Internationalization Services': {
            availableLanguages: ['en', 'de'],
            defaultLanguage: 'en'
        },
        'Mashroom Http Proxy Services': {
            rejectUntrustedCerts: false,
            poolMaxSockets: 10
        },
        'Mashroom WebSocket Services': {
            restrictToRoles: null,
            enableKeepAlive: true,
            keepAliveIntervalSec: 15,
            maxConnections: 2000
        },
        'Mashroom Messaging Services': {
            externalProvider: 'Mashroom Messaging External Provider AMQP',
            externalTopics: [],
            userPrivateBaseTopic: 'user',
            enableWebSockets: true,
            topicACL: './topic_acl.json'
        },
        'Mashroom Portal Remote App Registry Kubernetes': {
            k8sNamespaces: ['default'],
            serviceNameFilter: 'microfrontend-.*'
        },
        'Mashroom Messaging External Provider AMQP': {
            brokerTopicExchangePrefix: '/topic/',
            brokerTopicMatchAny: '#',
            brokerHost: RABBITMQ_HOST,
            brokerPort: RABBITMQ_PORT,
            brokerUsername: RABBITMQ_USER,
            brokerPassword: RABBITMQ_PASSWORD
        }
    }
};
