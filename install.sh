#!/bin/bash
/usr/local/bin/virtualenv .
source ./bin/activate
./bin/pip install -U -r requirements.txt
fab vendor_formulas
salt_thin=`sudo salt-run thin.generate`
cp $salt_thin ./

uuid=`python - <<END
import uuid
print str(uuid.uuid4())
END`

# THIS INSERTS A PENULTIMATE LINE
sed "$((` wc -l Dockerfile|awk '{ print $1 }'` - 1)) a\\
RUN echo $uuid && cd /tmp && python salt-call --local state.sls metrics.server\\
" Dockerfile > Dockerfile.new
rm Dockerfile && mv Dockerfile.new Dockerfile
docker build -t metrics .
