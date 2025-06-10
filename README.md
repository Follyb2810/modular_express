# modular_template
## Feature Generator

A simple script to generate boilerplate code for new features in a Node.js/Express application.

## Usage 

## add to you src folder
## include this to your script in package.json
```bash

    "create-feature": "ts-node src/create-feature.ts"
```
### then run with the folder name
```bash
npm run create-feature <feature-name> 
        :eg npm run create-feature product

For a given feature name (e.g., user), the script will create:

user.controller.ts - Controller with basic CRUD methods

user.dto.ts - DTO interface

user.model.ts - Mongoose model

user.service.ts - Service file

user.routes.ts - Express router

user.mapper.ts - DTO mapper

user.repository.ts - Empty repository file

```# modular_express
# modular_express
