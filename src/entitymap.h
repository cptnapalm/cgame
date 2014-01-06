#ifndef ENTITYMAP_H_YGLNG310
#define ENTITYMAP_H_YGLNG310

#include <stdbool.h>

#include "entity.h"

/*
 * map of Entity -> int
 */

typedef struct EntityMap EntityMap;

EntityMap *entitymap_new(int def); /* def is value for unset keys */
void entitymap_clear(EntityMap *emap);
void entitymap_free(EntityMap *emap);

void entitymap_set(EntityMap *emap, Entity ent, int val);
int entitymap_get(EntityMap *emap, Entity ent);
Entity entitymap_get_bound(EntityMap *emap); /* get 1 + max key, 0 if empty */

/* convenience macro to hide ugly casts */
#define entitymap_get_type(type, emap, ent) \
    ((type) entitymap_get(emap, ent))

#endif
