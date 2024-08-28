![Basic_Github_Actions_Workflow](https://github.com/Fleaurent/github_actions_docker/actions/workflows/Basic_Github_Actions_Workflow.yml/badge.svg)
![Custom_Container_Workflow](https://github.com/Fleaurent/github_actions_docker/actions/workflows/Custom_Container_Workflow.yml/badge.svg)
![Publish_Github_Pages_CI](https://github.com/Fleaurent/github_actions_docker/actions/workflows/Publish_Github_Pages_CI.yml/badge.svg)

# Github Actions Docker Doxygen  

- [1. Using Public Images in GitHub Actions](#1-using-public-images-in-github-actions)
- [2. Using Custom Docker Images in GitHub Actions](#2-using-custom-docker-images-in-github-actions)
  - [2.1. Build and Push the Custom Docker Image Locally to GitHub Container Registry](#21-build-and-push-the-custom-docker-image-locally-to-github-container-registry)
  - [2.2. Build and Push Custom Docker Images in GitHub Actions to GitHub Container Registry](#22-build-and-push-custom-docker-images-in-github-actions-to-github-container-registry)
- [3. GitHub Pages Action](#3-github-pages-action)

___

## 1. Using Public Images in GitHub Actions

`.github/workflows/basic_workflow.yml`  

```yml
# This is a basic workflow to help you get started with Actions

name: Basic_Github_Actions_Workflow

# Controls when the workflow will run
on:
  # Triggers the workflow on push or pull request events but only for the main branch
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

  # Allows you to run this workflow manually from the Actions tab
  workflow_dispatch:

# A workflow run is made up of one or more jobs that can run sequentially or in parallel
jobs:
  # This workflow contains a single job called "basic_job"
  basic_job:
    # The type of runner that the job will run on
    runs-on: ubuntu-latest

    # Steps represent a sequence of tasks that will be executed as part of the job
    steps:
      # Checks-out your repository under $GITHUB_WORKSPACE, so your job can access it
      - name: Checkout
        uses: actions/checkout@v4

      # Runs a single command using the runners shell
      - name: Run a one-line script
        run: echo Hello, world!

      # Runs a set of commands using the runners shell
      - name: Run a multi-line script
        run: |
          echo Add other actions to build,
          echo test, and deploy your project.
          
  use_vm_job:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Run on VM
        run: |
          echo This job does not specify a container.
          echo It runs directly on the virtual machine.

  use_public_container_job:
    runs-on: ubuntu-latest
    container: node:10.16-jessie
    steps:

      - name: Run in container
        run: |
          echo This job does specify a container.
          echo It runs in the container instead of the VM.
```

___

## 2. Using Custom Docker Images in GitHub Actions

### 2.1. Build and Push the Custom Docker Image Locally to GitHub Container Registry

https://stackoverflow.com/questions/64033686/how-can-i-use-private-docker-image-in-github-actions  
&rarr; using github container registry `ghcr.io`  

**1. Generate Access Token:**  

GitHub Account > Settings > Developer Settings > Personal Access Tokens  
with read:packages, write:packages and delete:packages permissions  
&rarr; `DOCKER_CONTAINER_REGISTRY_TOKEN`  

**2. Push the Image to GitHub Container Registry:**

i.e. build&push the custom image to the ghcr container registry  

```bash
# Step 1: Build image locally
$ docker build -t <IMAGE_NAME>:<IMAGE_TAG> .

# Step 2: Save token as a local environment variable and login to GitHub Container Registry
$ export DOCKER_CONTAINER_REGISTRY_TOKEN=<token>
$ echo $DOCKER_CONTAINER_REGISTRY_TOKEN | docker login ghcr.io -u <YOUR_USERNAME> --password-stdin

# Step 3: Build&Push the custom Docker image to GitHub Container Registry
$ docker build -t <IMAGE_NAME>:<IMAGE_TAG> .
$ docker tag <IMAGE_NAME>:<IMAGE_TAG> ghcr.io/<YOUR_USERNAME>/<IMAGE_NAME>:<IMAGE_TAG>
$ docker push ghcr.io/<YOUR_USERNAME>/<IMAGE_NAME>:<IMAGE_TAG>
```

**3. Use the Image in Github Actions:**  

save token as a repository secret for the github action:  
Repository > Settings > Secrets and variables > Actions > New repository secret  
&rarr; `DOCKER_CONTAINER_REGISTRY_TOKEN`  

`.github/workflows/custom_container_workflow.yml`

```yml
name: Custom_Container_Workflow

# Controls when the workflow will run
on:
  # Triggers the workflow on push or pull request events but only for the main branch
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

  # Allows you to run this workflow manually from the Actions tab
  workflow_dispatch:

jobs:
  # The job that will use the container image you just pushed to ghcr.io
  custom_container_job:
    runs-on: ubuntu-latest

    container:
      image: ghcr.io/<YOUR_USERNAME>/<IMAGE_NAME>:<IMAGE_TAG>
      credentials:
        username: <YOUR_USERNAME>
        password: ${{  secrets.DOCKER_CONTAINER_REGISTRY_TOKEN }}

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: run in custom container
        shell: bash
        run: |
          # Whatever commands you want to run here using the container with your new Docker image at ghcr.io!
          echo "--This is running in my custom Docker image--"
```

### 2.2. Build and Push Custom Docker Images in GitHub Actions to GitHub Container Registry

`.github/workflows/custom_container_workflow.yml`  

```yml
name: Custom_Container_Workflow

# Controls when the workflow will run
on:
  # Triggers the workflow on push or pull request events but only for the main branch
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

  # Allows you to run this workflow manually from the Actions tab
  workflow_dispatch:

jobs:
  build_and_push_new_image_job:
    # https://github.com/docker/login-action
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Log in to GitHub Container Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.DOCKER_CONTAINER_REGISTRY_TOKEN }}

      - name: Build and push Docker image
        run: |
          docker build -t ghcr.io/fleaurent/basic_image:latest .
          docker push ghcr.io/fleaurent/basic_image:latest
  
  use_new_image_job:
    needs: build_and_push_new_image_job
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/fleaurent/basic_image:latest
      credentials:
        username: fleaurent
        password: ${{  secrets.DOCKER_CONTAINER_REGISTRY_TOKEN }}
    steps:
      - name: Run in new container
        run: |
          echo "--This is running in my new Docker image--"
```

___

## 3. GitHub Pages Action

https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site  

https://time2hack.com/auto-publish-github-pages-github-actions/  

https://github.com/peaceiris/actions-gh-pages  

1. update image: install git-lfs  
   https://github.com/git-lfs/git-lfs/issues/4346
   `Dockerfile`  

```bash
FROM alpine:latest

RUN apk --update add doxygen graphviz git git-lfs &&\
    rm -rf /var/cache/apk/*

CMD ["doxygen", "-v"]

WORKDIR /tmp
```

2. build and push the image  

```bash
$ docker build -t doxygen_image .
$	docker tag doxygen_image:latest ghcr.io/fleaurent/doxygen_image:latest
$ docker push ghcr.io/fleaurent/doxygen_image:latest
```

3. update the github action  

`publish_github_pages.yml`  

```yml
name: Publish_Github_Pages_CI

on:
  push:
    branches: [ main ]

jobs:
  deploy_job:  
    runs-on: ubuntu-latest  # ubuntu-22.04
    
    container:
      image: ghcr.io/fleaurent/doxygen_image:latest
      credentials:
        username: fleaurent
        password: ${{  secrets.DOCKER_CONTAINER_REGISTRY_TOKEN }}
        
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: generate documentation
        run: doxygen Doxyfile
        
      - name: copy documentation to the build directory
        run: cp -r html/ build/
        
    # Push the HTML files to github-pages
      - name: GitHub Pages action
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./build
```

4. set up github pages in the github repository:  
  the files are pushed to a separate branch `gh-pages`  
  ![github_pages_settings](images/github_pages_settings.png)  

&rarr; [GitHub Pages](https://fleaurent.github.io/github_actions_docker/)  
