class SchemaObject {
	[string] ToJson() {
		return ConvertTo-Json -InputObject $this
	}
}

class BootSource : SchemaObject {
	[string]$kernel_image_path
	[string]$boot_args
}

class Drive : SchemaObject {
	[string]$drive_id
	[string]$path_on_host
	[bool]$is_root_device
	[string]$partuuid
	[bool]$is_read_only
	[RateLimiter]$rate_limiter
}

class RateLimiter : SchemaObject {
	[TokenBucket]$bandwidth
	[TokenBucket]$ops
}

class TokenBucket : SchemaObject {
	[int]$size
	[int]$one_time_burst
	[int]$refill_time
}

class InstanceActionInfo : SchemaObject {
	[ValidateSet('BlockDeviceRescan', 'InstanceStart')]
	[string]$action_type
	[string]$payload
}
