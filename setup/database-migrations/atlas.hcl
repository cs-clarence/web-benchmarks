variable "destructive" {
    type        = bool
    default     = false
    description = "Whether to destructively drop objects"
}

locals {
    url            = getenv("DATABASE_URL")
    dev            = getenv("MIGRATION_DEV_DATABASE_URL")
    src            = "file://./src/schemas"
    migrations_dir = "file://./src/migrations"
    sdl_format     = "{{ sql . \"  \" }}"
}

env {
    name = atlas.env
    url  = local.url
    dev  = local.dev

    src = local.src
    schemas = [ "public" ]

    migration {
        // baseline = "20240501054945"
        dir      = local.migrations_dir
    }

    format {
        migrate {
            # apply  = local.format
            diff = local.sdl_format
            # lint   = local.format
            # status = local.format
        }

        schema {
            # apply   = local.format
            diff    = local.sdl_format
            inspect = local.sdl_format
        }
    }

    diff {
        skip {
            drop_column      = var.destructive
            drop_table       = var.destructive
            drop_view        = var.destructive
            drop_schema      = var.destructive
            drop_foreign_key = var.destructive
            drop_func        = var.destructive
            drop_index       = var.destructive
            drop_proc        = var.destructive
            drop_trigger     = var.destructive
        }
    }
}
