#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib';
import { TechhealthMigrationStack } from '../lib/techhealth-migration-stack';

const app = new cdk.App();
new TechhealthMigrationStack(app, 'TechhealthMigrationStack', {
  env: {
    account: process.env.CDK_DEFAULT_ACCOUNT,  // Uses current AWS account
    region: process.env.CDK_DEFAULT_REGION,    // Uses current AWS region
  },
});