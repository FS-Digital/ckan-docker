FROM ckan/ckan-base:2.11

# 1. Switch to root to install extensions and modify files
USER root

# 2. Install Scheming Extension
RUN pip3 install -e 'git+https://github.com/ckan/ckanext-scheming.git@master#egg=ckanext-scheming'

# 3. Copy the Schema file
# We ensure the parent directory exists and change ownership to the ckan user
COPY stockton_schema.json /srv/app/schemas/stockton_schema.json
RUN chown ckan:ckan /srv/app/schemas/stockton_schema.json

# --- Existing Configuration below ---

# Copy custom initialization scripts
COPY --chown=ckan-sys:ckan-sys docker-entrypoint.d/* /docker-entrypoint.d/

# Apply any patches needed to CKAN core or any of the built extensions
COPY --chown=ckan-sys:ckan-sys patches ${APP_DIR}/patches

# 4. Switch back to ckan user for runtime security
USER ckan

RUN for d in $APP_DIR/patches/*; do \
        if [ -d $d ]; then \
            for f in `ls $d/*.patch | sort -g`; do \
                cd $SRC_DIR/`basename "$d"` && echo "$0: Applying patch $f to $SRC_DIR/`basename $d`"; \
                patch -p1 < "$f" ; \
            done ; \
        fi ; \
    done