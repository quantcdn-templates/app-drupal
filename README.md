# Node Express QuantCDN starter template

![Template screenshot](quant/screenshot.png?raw=true)

This template provides everything you need to get started with [Express](https://expressjs.com/) on QuantCDN.

Click the "Deploy to Quant" button to create a new repo, QuantCDN project, and deployment pipelines.

[![Deploy to Quant](https://www.quantcdn.io/img/quant-deploy-btn-sml.svg)](https://dashboard.quantcdn.io/deploy/app/step-one?template=app-node-express)


### Installation

```
$ npm i
```

### Build & test locally

```
$ npm run dev
```

### Build & test in docker container

To test the same container that gets deployed to cloud, run the following:
```
docker-compose up
```

Changes to the codebase in `src` will be reflected immediately.

### Deployment

This template automatically preconfigures your CI pipeline to deploy to Quant. This means you simply need to edit the codebase in the `src` folder and commit changes to trigger the build & deploy process.
