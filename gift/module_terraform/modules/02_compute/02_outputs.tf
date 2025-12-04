# ================================================
# Output Variables
# ================================================
output "codecommit" {
  description = "CodeCommit repository information"
  value = {
    repository_name = aws_codecommit_repository.this.repository_name
    clone_url_http  = aws_codecommit_repository.this.clone_url_http
    clone_url_ssh   = aws_codecommit_repository.this.clone_url_ssh
  }
}
