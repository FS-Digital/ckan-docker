FROM ckan/ckan-base:2.11

# ### Install Scheming Extension ###
RUN pip3 install -e 'git+https://github.com/ckan/ckanext-scheming.git@master#egg=ckanext-scheming'

# ### Copy the Stockton Schema into the image ###
# Ensure stockton_schema.json is in the 'ckan' folder alongside this Dockerfile before deploying,
# or update the path below to match where it is relative to the build context.
COPY stockton_schema.json /srv/app/schemas/stockton_schema.json

# Copy custom initialization scripts
COPY --chown=ckan-sys:ckan-sys docker-entrypoint.d/* /docker-entrypoint.d/

# Apply any patches needed
COPY --chown=ckan-sys:ckan-sys patches ${APP_DIR}/patches

USER ckan

RUN for d in $APP_DIR/patches/*; do \
        if [ -d $d ]; then \
            for f in `ls $d/*.patch | sort -g`; do \
                cd $SRC_DIR/`basename "$d"` && echo "$0: Applying patch $f to $SRC_DIR/`basename $d`"; \
                patch -p1 < "$f" ; \
            done ; \
        fi ; \
    done