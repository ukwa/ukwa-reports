#
# This is a bit knarly but it helpfully flattens the Solr JSON API reponse
# (which is a kind of tree shape) into a flat table that Pandas can work with.
#
# See [Solr's JSON Facet API](https://lucene.apache.org/solr/guide/8_4/json-facet-api.html)
#

def flatten_solr_buckets(solr_facets):
    flat = []
    for key in solr_facets:
        if isinstance(solr_facets[key], dict):
            for vals in _flatten_facet_buckets(key, solr_facets):
                flat.append(vals.copy())
    return flat

def _flatten_facet_buckets(facet_name, bucket, values={}):
    subfacets = []
    for bucket_name in bucket:
        if isinstance(bucket[bucket_name],dict):
            subfacets.append(bucket_name)
    if len(subfacets) > 0:
        for bucket_name in subfacets:
            for sub_bucket in bucket[bucket_name]['buckets']:                
                values[bucket_name] = sub_bucket['val']
                for sub_values in _flatten_facet_buckets(bucket_name, sub_bucket, values.copy()):
                    yield sub_values
            # Also deal with the special 'missing' bucket:
            if 'missing' in bucket[bucket_name]:
                values[bucket_name] = "missing"
                for sub_values in _flatten_facet_buckets(bucket_name, bucket[bucket_name]['missing'], values.copy()):
                    yield sub_values
    else:
        for bucket_name in bucket:
            if bucket_name != 'val':
                values[bucket_name] = bucket[bucket_name]
        yield values
        

