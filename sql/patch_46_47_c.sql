# patch_46_47_c.sql
#
# title: extend external_db db_release
#
# description:
# Make db_release column of external_db VARCHAR(255)

ALTER TABLE external_db CHANGE COLUMN db_release db_release VARCHAR(255);

# patch identifier
INSERT INTO meta (meta_key, meta_value) VALUES ('patch', 'patch_46_47_c.sql|extend_db_release');


