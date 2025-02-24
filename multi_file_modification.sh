#!/bin/bash

# Function to apply rules to a file
apply_rules() {
    local file_path=$1
    local rules=$2

    # Example rule: Remove content starting from "wp_localize_script(" to "'wpst' ), ) );"
    if [[ $rules == *"functionschg"* ]]; then
      
	  
	  sed -i '/if ( is_single() &&/ { :a; N; /}/!ba; d; }' "$file_path"
sed -i '/wp_localize_script(/,/'wpst' ),/d' "$file_path"


# Remove lines containing specific text
sed -i '/\/inc\/class-video-submitter.php/d' "$file_path"
sed -i '/\/admin\/import\/wpst-importer.php/d' "$file_path"
sed -i '/jax-login-register.php/d' "$file_path"

# Add new content to the end of the file
cat <<EOL >>"$file_path"

add_action('init', 'stop_heartbeat', 1);
function stop_heartbeat() {
    wp_deregister_script('heartbeat');
}
remove_action('wp_head', 'print_emoji_detection_script', 7);
remove_action('wp_print_styles', 'print_emoji_styles');
remove_action('wp_head', 'wp_oembed_add_discovery_links');
remove_action('wp_head', 'wp_oembed_add_host_js');
add_filter('xmlrpc_enabled', '__return_false');
remove_action('wp_head', 'rsd_link'); 
remove_action('wp_head', 'wlwmanifest_link'); 
function disable_rss_feeds() {
    remove_action('wp_head', 'feed_links', 2);
    remove_action('wp_head', 'feed_links_extra', 3);
}
add_action('after_setup_theme', 'disable_rss_feeds');
remove_action('wp_head', 'wp_generator'); 
remove_action('wp_head', 'wp_shortlink_wp_head'); 
add_action('wp_enqueue_scripts', 'disable_block_editor_css', 100);
function disable_block_editor_css() {
    wp_dequeue_style('wp-block-library'); 
    wp_dequeue_style('wp-block-library-theme');
}
add_filter('use_block_editor_for_post', '__return_false');
add_action('wp_default_scripts', 'remove_jquery_migrate');
function remove_jquery_migrate(\$scripts) {
    if (!is_admin() && isset(\$scripts->registered['jquery'])) {
        \$script = \$scripts->registered['jquery'];
        if (\$script->deps) {
            \$script->deps = array_diff(\$script->deps, array('jquery-migrate'));
        }
    }
}
add_action('wp', function() {
    if (is_single() && 'off' !== xbox_get_field_value('wpst-options', 'enable-views-system')) {
        $post_id = get_the_ID();
        $pending_key = 'wpst_pending_views_' . $post_id;
        $pending_views = (int) get_option($pending_key, 0) + 1; // Persistent storage
        update_option($pending_key, $pending_views, false); // No autoload
        error_log('Pending views incremented for ' . $post_id . ': ' . $pending_views);
    }
});

function wpst_post_like_handler() {
    check_ajax_referer('ajax-nonce', 'nonce');
    if (!isset($_POST['post_id']) || !isset($_POST['post_like'])) {
        wp_send_json_error(array('message' => 'Missing parameters'));
    }
    $post_id = intval($_POST['post_id']);
    $post_like = sanitize_text_field($_POST['post_like']);

    if ($post_like === 'like') {
        $likes = intval(get_post_meta($post_id, 'likes_count', true)) + 1;
        update_post_meta($post_id, 'likes_count', $likes);
    } elseif ($post_like === 'dislike') {
        $dislikes = intval(get_post_meta($post_id, 'dislikes_count', true)) + 1;
        update_post_meta($post_id, 'dislikes_count', $dislikes);
    }

    delete_transient('wpst_post_data_' . $post_id);
    error_log('Transient cleared for post ' . $post_id);

    $response = array(
        'likes' => wpst_get_human_number(intval(get_post_meta($post_id, 'likes_count', true))),
        'dislikes' => wpst_get_human_number(intval(get_post_meta($post_id, 'dislikes_count', true))),
        'percentage' => wpst_get_post_like_rate($post_id),
        'progressbar' => wpst_get_post_like_rate($post_id),
        'button' => $post_like === 'like' ? 'Liked' : 'Disliked',
        'nbrates' => 1,
        'alreadyrate' => false
    );
    wp_send_json_success($response);
    wp_die();
}
add_action('wp_ajax_nopriv_post-like', 'wpst_post_like_handler');
add_action('wp_ajax_post-like', 'wpst_post_like_handler');


EOL


    fi

    # Example rule: Replace "foo" with "bar"
    if [[ $rules == *"extrachg"* ]]; then
       
	    sed -i '/\/\*\*$/,/back_header'\'' );/d' "$file_path"
	   
    fi

    # Example rule: Delete lines containing "DEBUG"
    if [[ $rules == *"ajaxfile"* ]]; 
	
	  cat > "$file_path" << 'EOF'
<?php
function wpst_get_async_post_data() {
    check_ajax_referer('ajax-nonce', 'nonce');
    if (!isset($_POST['post_id'])) {
        wp_send_json_error(array('message' => 'post_id parameter is missing'));
    }
    $post_id = intval($_POST['post_id']);
    
    $transient_key = 'wpst_post_data_' . $post_id;
    $response = get_transient($transient_key);

    if (false === $response) {
        error_log('Cache miss for post ' . $post_id);
        $response = array();
        if ('off' !== xbox_get_field_value('wpst-options', 'enable-views-system')) {
            $pending_key = 'wpst_pending_views_' . $post_id;
            $pending_views = (int) get_option($pending_key, 0);
            $views = (int) get_post_meta($post_id, 'post_views_count', true);
            if ($pending_views > 0) {
                $views += $pending_views;
                update_post_meta($post_id, 'post_views_count', $views);
                delete_option($pending_key);
                error_log('Flushed ' . $pending_views . ' views to post ' . $post_id);
            }
            $response['views'] = wpst_get_human_number($views);
        }
        if ('off' !== xbox_get_field_value('wpst-options', 'enable-rating-system')) {
            $response['likes'] = wpst_get_human_number(intval(get_post_meta($post_id, 'likes_count', true)));
            $response['dislikes'] = wpst_get_human_number(intval(get_post_meta($post_id, 'dislikes_count', true)));
            $response['rating'] = wpst_get_post_like_rate($post_id);
        }
        set_transient($transient_key, $response, 10 * MINUTE_IN_SECONDS);
    } else {
        error_log('Cache hit for post ' . $post_id);
    }
    wp_send_json_success($response);
    wp_die();
}
add_action('wp_ajax_nopriv_get-post-data', 'wpst_get_async_post_data');
add_action('wp_ajax_get-post-data', 'wpst_get_async_post_data');
EOF

    
if [[ $rules == *"mainjs"* ]]; then
sed -i '/( function() {/,/return; }() );/d' "$file_path"

        # Insert new content at line 379
        sed -i '379i
(function($) {
    var isPost = $('body.single-post').length > 0;
    if (!isPost) return;
    var postId = $('article.post').attr('id').replace('post-', '');
    console.log('Main JS running for post ' + postId);

    function loadPostData() {
        $.ajax({
            type: 'post',
            url: wpst_ajax_var.url,
            dataType: 'json',
            data: {
                action: 'get-post-data',
                nonce: wpst_ajax_var.nonce,
                post_id: postId,
                _t: new Date().getTime()
            }
        }).done(function(response) {
            console.log('Response:', response);
            if (!response.success) return;
            if (response.data.views) $('#video-views span').text(response.data.views);
            if (response.data.likes) $('.likes_count').text(response.data.likes);
            if (response.data.dislikes) $('.dislikes_count').text(response.data.dislikes);
            if (response.data.rating) {
                $('.percentage').text(response.data.rating + '%');
                $('.rating-bar-meter').css('width', response.data.rating + '%');
            }
        }).fail(function(errorData) {
            console.error('AJAX failed:', errorData);
        });
    }

    $(document).ready(loadPostData); // Initial load
    $(window).on('pageshow', loadPostData); // Mobile back/forward cache
})(jQuery);' "$file_path"
     fi
    
if [[ $rules == *"nofb"* ]]; then
        sed -i '/<!-- Meta/,/height" content="200" \/>/d' "$file_path"
    fi



# Define the files and their associated rules
declare -A file_rules=(
    ["/var/www/tstmusz/wp-content/themes/test/functions.php"]="functionschg"
    ["/var/www/tstmusz/wp-content/themes/test/inc/extras.php"]="extrachg"
    ["/var/www/tstmusz/wp-content/themes/test/inc/ajax-get-async-post-data.php"]="ajaxfile"
	["/var/www/tstmusz/wp-content/themes/test/assets/js/main.js"]="mainjs"
	["/var/www/tstmusz/wp-content/themes/test/inc/meta-social.php"]="nofb"
)

# Loop through the files and apply the rules
for file_path in "${!file_rules[@]}"; do
    apply_rules "$file_path" "${file_rules[$file_path]}"
done

echo "Modifications complete."
