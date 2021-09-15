# GitHub Action to Sync S3 Bucket and invalidate the CloudFront cache and compile JS files using Google Closure 🔄

yarn global add google-closure-compiler
google-closure-compiler --js s3-static/nv.js --js_output_file s3-static/public/nv.js
cp -f s3-static/public/nv.js s3-static/public/nv.min.js


This simple action uses the [Google Closure Compiler](https://developers.google.com/closure/compiler) and [vanilla AWS CLI](https://docs.aws.amazon.com/cli/index.html) to compile JS files in directory and sync a that directory (either from your repository or generated during your workflow) with a remote S3 bucket and afterwards invalidate the CloudFront cache.


## Usage

### `workflow.yml` Example

Place in a `.yml` file such as this one in your `.github/workflows` folder. [Refer to the documentation on workflow YAML syntax here.](https://help.github.com/en/articles/workflow-syntax-for-github-actions)

As of v0.3.0, all [`aws s3 sync` flags](https://docs.aws.amazon.com/cli/latest/reference/s3/sync.html) are optional to allow for maximum customizability (that's a word, I promise) and must be provided by you via `args:`.

#### The following example includes optimal defaults for a public static website:

- `--acl public-read` makes your files publicly readable (make sure your [bucket settings are also set to public](https://docs.aws.amazon.com/AmazonS3/latest/dev/WebsiteAccessPermissionsReqd.html)).
- `--follow-symlinks` won't hurt and fixes some weird symbolic link problems that may come up.
- Most importantly, `--delete` **permanently deletes** files in the S3 bucket that are **not** present in the latest version of your repository/build.
- **Optional tip:** If you're uploading the root of your repository, adding `--exclude '.git/*'` prevents your `.git` folder from syncing, which would expose your source code history if your project is closed-source. (To exclude more than one pattern, you must have one `--exclude` flag per exclusion. The single quotes are also important!)

```yaml
name: Upload Website

on:
  push:
    branches:
    - master

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - uses: kersvers/s3-sync-with-cloudfront-invalidation@v1.0.0
      with:
        args: --acl public-read --follow-symlinks --delete
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        AWS_S3_BUCKET: ${{ secrets.AWS_S3_BUCKET }}
        DISTRIBUTION_ID: 'EQDXXXXO18XXX'
        AWS_REGION: 'eu-west-1'   # optional: defaults to us-east-1
        SOURCE_DIR: 'public'      # optional: defaults to entire repository
        DEST_DIR: 'subdirectory'      # optional: defaults to the root of the bucket
        COMPILE_JS: 'min' #optional: defaults to none (no compile)
```


### Configuration

The following settings must be passed as environment variables as shown in the example. Sensitive information, especially `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`, should be [set as encrypted secrets](https://help.github.com/en/articles/virtual-environments-for-github-actions#creating-and-using-secrets-encrypted-variables) — otherwise, they'll be public to anyone browsing your repository's source code and CI logs.

| Key | Value | Suggested Type | Required | Default |
| ------------- | ------------- | ------------- | ------------- | ------------- |
| `AWS_ACCESS_KEY_ID` | Your AWS Access Key. [More info here.](https://docs.aws.amazon.com/general/latest/gr/managing-aws-access-keys.html) | `secret env` | **Yes** | N/A |
| `AWS_SECRET_ACCESS_KEY` | Your AWS Secret Access Key. [More info here.](https://docs.aws.amazon.com/general/latest/gr/managing-aws-access-keys.html) | `secret env` | **Yes** | N/A |
| `AWS_S3_BUCKET` | The name of the bucket you're syncing to. For example, `jarv.is` or `my-app-releases`. | `secret env` | **Yes** | N/A |
| `DISTRIBUTION_ID` | The ID of the CloudFront distribution you wish to invalidate the cache for. | `env` | **Yes** | N/A |
| `AWS_REGION` | The region where you created your bucket. Set to `us-east-1` by default. [Full list of regions here.](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-available-regions) | `env` | No | `us-east-1` |
| `AWS_S3_ENDPOINT` | The endpoint URL of the bucket you're syncing to. Can be used for [VPC scenarios](https://aws.amazon.com/blogs/aws/new-vpc-endpoint-for-amazon-s3/) or for non-AWS services using the S3 API, like [DigitalOcean Spaces](https://www.digitalocean.com/community/tools/adapting-an-existing-aws-s3-application-to-digitalocean-spaces). | `env` | No | Automatic (`s3.amazonaws.com` or AWS's region-specific equivalent) |
| `SOURCE_DIR` | The local directory (or file) you wish to sync/upload to S3. For example, `public`. Defaults to your entire repository. | `env` | No | `./` (root of cloned repository) |
| `DEST_DIR` | The directory inside of the S3 bucket you wish to sync/upload to. For example, `my_project/assets`. Defaults to the root of the bucket. | `env` | No | `/` (root of bucket) |
| `COMPILE_JS` | Choose if to minify JS files using Google Clousure Library. min = Comile and replace, both = Compile to new file named FILE.min.js and keep original. Defaults to no. | `env` | No | 0 |

## License

This project is distributed under the [MIT license](LICENSE.md).
