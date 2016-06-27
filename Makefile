# Copyright 2016 The Kubernetes Authors All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

all: docker push plot

PLOTTER_DOCKER_IMAGE       := girishkalele/netperf-plotperf:1.0

docker: 
	mkdir -p Dockerbuild && \
	cp -f Dockerfile Dockerbuild/ && \
	cp -f plotperf.py Dockerbuild/ &&\
	docker build -t $(PLOTTER_DOCKER_IMAGE) Dockerbuild/ 

push: docker
	gcloud docker push $(PLOTTER_DOCKER_IMAGE)

clean:
	@rm -f Dockerbuild/*

# Use this target 'plot' to run the docker container that will pick up netperf-latest.csv and render it into png and svg images
plot: netperf-latest.csv
	mkdir -p tmp && cp netperf-latest.csv tmp/ &&\
	docker run --detach=false -v `pwd`/tmp:/plotdata $(PLOTTER_DOCKER_IMAGE) --csv /plotdata/netperf-latest.csv --suffix netperf-latest &&\
	cp tmp/* .