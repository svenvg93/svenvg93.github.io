---
title: How I use GitHub Actions to publish my blog
description: A step-by-step guide on automating the deployment of your blog using GitHub Actions for continuous publishing.
date: 2025-01-16
categories: 
  - hosting
  - cloud
tags: 
  - cloudflare
  - github
  - jekyll
image:
  path: /assets/img/headers/2025-01-16-github-actions-cloudflare-pages.jpg
  alt: Photo by Ilya Pavlov on Unsplash
---

This blog is hosted on Cloudflare Pages for optimal loading speed. As a static website built with Jekyll and the Chirpy theme, it relies on a trigger to prompt Cloudflare to rebuild and publish the site. In a previous post, I showed how to set up Jekyll with Cloudflare Pages, where Cloudflare monitors your Git repository and automatically rebuilds the site with every merge or commit.

Jekyll allows posts to be scheduled based on the date in the frontmatter, so I often write posts in advance while working on something new. This means there won’t always be a commit or merge to trigger a rebuild on the right date. Instead of relying on Cloudflare to watch the repository, we needed a trigger to rebuild the site. This is where GitHub Actions comes in.

In this post, we’ll set up GitHub Actions to leverage the Cloudflare API, triggering a rebuild of your blog whenever you need it.

## Cloudflare API 

The GitHub Action needs access to your Cloudflare account in order to trigger the rebuild of the website. To enable this, you’ll need to create an API token in your Cloudflare account and securely store it in GitHub Secrets, ensuring that the GitHub Action can authenticate and interact with Cloudflare’s API. This token will allow the action to trigger a rebuild whenever necessary, without compromising the security of your account.

1. Go to the Cloudflare [API page](https://dash.cloudflare.com/profile/api-tokens) and log in with your Cloudflare account.
2.	Create API Key:
  - Select **Create Token**.
  - Choose the template **Create Custom Token**.
  - Fill in the token name like: **Deploy Blog GH Actions**
  - Under Permissions select **Account**, **Cloudflare Pages**, **Edit**
  - Click on **Continue to Summery** 
4.	Click on **Create Token** to generate the token’s secret.
5.	Make sure to save this API key securely, as you will need it later for configuring the Github Repro Secrets.


### Cloudflare Page

Because the Github does not have a ability to create a project within Cloudflare we need to make an empty one. 

1.	Visit [Cloudflare Dashboard](https://dash.cloudflare.com/).
2.	Go to **Compute (Workers)** -> **Workers & Pages**.
3.	Click on **Create** and navigate to Pages.
4.	Select **Upload assets**.
5.  Fill in the project name
6.  Click **Create Project**
7. In the left top corner click on **Create an application** -> **Overview**



### Github Secrets
We need to configure GitHub to use the Account ID, API Token, and Project Name for deployment. Since this information is sensitive, we don’t want it to be visible to anyone. To secure it, we use GitHub Secrets to store this data in the repository. These secrets are encrypted and can only be accessed by the GitHub Action during workflow execution.

1. Go to your project's repository in GitHub.
2. Under your repository's name, select **Settings**.
3. Select **Secrets** > **Actions** > **New repository secret**.
4. Create the following secrets:
- CLOUDFLARE_ACCOUNT_ID
  - In the Name field, enter **CLOUDFLARE_ACCOUNT_ID**.
  - In the Value field, enter your Cloudflare account ID.
- CLOUDFLARE_API_TOKEN
  - In the Name field, enter **CLOUDFLARE_API_TOKEN**.
  - In the Value field, enter your Cloudflare API token.
- CLOUDFLARE_PROJECT
  - In the Name field, enter **CLOUDFLARE_PROJECT**.
  - In the Value field, enter the name of your Cloudflare Pages project.

## Github Action

Create a `.github/workflows/pages-deployment.yaml` file at the root of your project. The `.github/workflows/pages-deployment.yaml` file will contain the jobs you specify on the request.

```yaml
name: Deploy to Cloudflare Pages

on:
  schedule:
    - cron: '0 9 * * *'  # Runs every day at 09:00 UTC

  # Allow manual trigger
  workflow_dispatch:

jobs:
  build:
    name: Build
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2'
          bundler-cache: true

      - name: Install dependencies and build site
        run: |
          bundle install
          bundle exec jekyll build
        env:
          JEKYLL_ENV: "production"

      - name: Upload site artifact
        uses: actions/upload-artifact@v3
        with:
          name: site
          path: _site
          retention-days: 1

  test:
    name: Test
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2'
          bundler-cache: true

      - name: Download site artifact
        uses: actions/download-artifact@v3
        with:
          name: site
          path: _site

      - name: Test site
        run: |
          bundle exec htmlproofer _site \
            --disable-external \
            --ignore-urls "/^http:\/\/127.0.0.1/,/^http:\/\/0.0.0.0/,/^http:\/\/localhost/"

  deploy:
    name: Deploy
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Download site artifact
        uses: actions/download-artifact@v3
        with:
          name: site
          path: _site

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install Wrangler
        run: npm install -g wrangler

      - name: Deploy to Cloudflare Pages
        uses: cloudflare/wrangler-action@v3
        with:
          apiToken: {% raw %}${{ secrets.CLOUDFLARE_API_TOKEN }}{% endraw %}
          accountId: {% raw %}${{ secrets.CLOUDFLARE_ACCOUNT_ID }}{% endraw %}
          command: {% raw %}pages deploy _site --project-name=${{ secrets.CLOUDFLARE_PROJECT }}{% endraw %}
          gitHubToken: {% raw %}${{ secrets.GITHUB_TOKEN }}{% endraw %}
```
{: file='pages-deployment.yaml'}
Now, every day at 09:00 UTC, Cloudflare is triggered to rebuild and republish the website. Before publishing, the site is built and thoroughly tested for any broken links to ensure everything is working as expected.
