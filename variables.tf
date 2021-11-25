variable "admin_role_name" {
  type        = string
  default     = "Admin"
  description = "Nome da Role com perfil administrativo"
}
variable "sor_bucket_name" {
  type        = string
  description = "Nome do bucket que sera criado para arquivos do tipo RAW"
}
variable "spec_bucket_name" {
  type        = string
  description = "Nome do bucket que será criado para arquivos do tipo PARQUET"
}

variable "glue_database_name" {
  type        = string
  description = "Nome do banco de dados de metadados do AWS Glue"
}

variable "accounts_allowed" {
  type        = list(any)
  description = "Lista de contas que são permitidas escrever no Data Lake"
}

variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "Região onde serão criados os recursos"
}