## Zooniverse Crowdsourcing Demo

Sends classifications in real time to show crowdsourcing concensus. 

### Installation

Requires node.js 0.8.x

```
  git clone https://github.com/edpaget/crowdsourcing-demo
  npm install .
```

### Usage

Development Mode (assets are recompiled each connection) 
```
  NODE_ENV=development node index.js
```

Proudction Mode (assets are served from build folder)
```
  haw build -r front-end/
  NODE_ENV=production node index.js
```
