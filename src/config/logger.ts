// const moment = require('moment')
// const winston = require('winston')
// const { createLogger, format, transports } = winston
// const { combine, printf } = format
// require('winston-daily-rotate-file');
// const { log: logConfigs, isTest } = require('../configs')

// const myFormat = printf(info => {
//   return `[${moment().format()}] ${info.level}: ${JSON.stringify(info.message)}`;
// })

// const dailyTransport = new winston.transports.DailyRotateFile({
//   filename: 'application-%DATE%.log',
//   datePattern: 'YYYY-MM-DD-HH',
//   zippedArchive: true,
//   maxSize: '20m',
//   maxFiles: '14d',
//   dirname: logConfigs.dir,
// });

// dailyTransport.on('rotate', function(oldFilename, newFilename) {
//   console.log(`daily.on(rotate): oldFilename ${oldFilename} newFilename ${newFilename}`)
// });


// const logger = createLogger({
//   format: combine(
//     myFormat
//   ),
//   transports: [
//     new transports.Console(),
//     dailyTransport,
//     // new transports.File({
//     //   filename: `${logConfigs.dir}/error.log`,
//     //   level: 'error'
//     // }),
//     // new transports.File({
//     //   filename: `${logConfigs.dir}/access.log`
//     // }),
    
//   ],
//   silent: isTest()
// })

// function logTrafic(req, res, next) {
//   logger.info({
//     method: req.method,
//     endpoint: req.originalUrl,
//   });
//   next();
// }

// module.exports = {
//   logger,
//   logTrafic,
// }
// const { createLogger, format, transports } = require('winston');
// const { combine, timestamp, printf, errors } = format;

// // Custom format for logs
// const customFormat = printf(({ level, message, timestamp, stack }) => {
//   return `${timestamp} ${level}: ${stack || message}`;
// });

// const logger = createLogger({
//   level: 'info',
//   format: combine(
//     timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
//     errors({ stack: true }),
//     customFormat
//   ),
//   transports: [
//     new transports.Console(),
//     new transports.File({ filename: 'logs/error.log', level: 'error' }),
//     new transports.File({ filename: 'logs/combined.log' })
//   ]
// });

// module.exports = logger;
// app.use(morgan('combined', {
//   stream: {
//     write: (message) => logger.info(message.trim())
//   }
// }));
// app.use((err, req, res, next) => {
//   logger.error(err); // logs full error with stack
//   res.status(500).json({ error: 'Something went wrong' });
// });
// app.listen(PORT, () => {
//   logger.info(`Server running on port ${PORT}`);
// });

// ├── logs/
// │   ├── combined.log
// │   └── error.log
