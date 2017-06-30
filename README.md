# canvas-api
Useful scripts for interacting with Canvas.

The scripts are self documenting. Just type "ruby \<scriptname\>" and it will explain how to use it.

Note that the scripts is a mixture of english and norwegian. You also have to install a separate canvas-api library as well as having a token to access a Canvas server. 
Read more about that part [https://docs.google.com/document/d/1npd17N198OHbUQWjieS-wc0bP7nDdWnUk4Je1NGPj1U/edit#heading=h.kanebux0f94q](https://docs.google.com/document/d/1npd17N198OHbUQWjieS-wc0bP7nDdWnUk4Je1NGPj1U/edit#heading=h.kanebux0f94q). 


# Docker
Since the scripts depend on ruby, curl, ssl etc., I've setup a docker file which could make it easier to get a working environment on your computer. 

## Step 1: Install Docker
Install Docker from [https://docs.docker.com/engine/installation/](https://docs.docker.com/engine/installation/)

## Step 2: Install Canvas-Api
From a terminal window on your mac or pc, pull the docker image

    docker pull mmooc/canvas-api

## Step 3: Start the docker image
From a terminal window on your mac or pc, start the docker image

    docker run -it mmooc/canvas-api




