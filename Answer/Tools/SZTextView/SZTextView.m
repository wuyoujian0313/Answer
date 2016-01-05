//
//  SZTextView.m
//  SZTextView
//
//  Created by glaszig on 14.03.13.
//  Copyright (c) 2013 glaszig. All rights reserved.
//

#import "SZTextView.h"

#define HAS_TEXT_CONTAINER [self respondsToSelector:@selector(textContainer)]
#define HAS_TEXT_CONTAINER_INSETS(x) [(x) respondsToSelector:@selector(textContainerInset)]

@interface SZTextView ()
@property (strong, nonatomic) UITextView *placeholderTextView;
@end

static NSString * const kAttributedPlaceholderKey = @"attributedPlaceholder";
static NSString * const kPlaceholderKey = @"placeholder";
static NSString * const kFontKey = @"font";
static NSString * const kAttributedTextKey = @"attributedText";
static NSString * const kTextKey = @"text";
static NSString * const kExclusionPathsKey = @"exclusionPaths";
static NSString * const kLineFragmentPaddingKey = @"lineFragmentPadding";
static NSString * const kTextContainerInsetKey = @"textContainerInset";
static NSString * const kTextAlignmentKey = @"textAlignment";

@implementation SZTextView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self preparePlaceholder];
    }
    return self;
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer
{
    self = [super initWithFrame:frame textContainer:textContainer];
    if (self) {
        [self preparePlaceholder];
    }
    return self;
}
#else
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self preparePlaceholder];
    }
    return self;
}
#endif

- (void)preparePlaceholder
{
    NSAssert(!self.placeholderTextView, @"placeholder has been prepared already: %@", self.placeholderTextView);
    // the label which displays the placeholder
    // needs to inherit some properties from its parent text view

    // account for standard UITextViewPadding

    CGRect frame = self.bounds;
    self.placeholderTextView = [[UITextView alloc] initWithFrame:frame];
    self.placeholderTextView.opaque = NO;
    self.placeholderTextView.backgroundColor = [UIColor clearColor];
    self.placeholderTextView.textColor = [UIColor colorWithWhite:0.7f alpha:0.7f];
    self.placeholderTextView.textAlignment = self.textAlignment;
    self.placeholderTextView.editable = NO;
    self.placeholderTextView.scrollEnabled = NO;
    self.placeholderTextView.userInteractionEnabled = NO;
    self.placeholderTextView.font = self.font;
    self.placeholderTextView.isAccessibilityElement = NO;
    self.placeholderTextView.contentOffset = self.contentOffset;
    self.placeholderTextView.contentInset = self.contentInset;

    if ([self.placeholderTextView respondsToSelector:@selector(setSelectable:)]) {
        self.placeholderTextView.selectable = NO;
    }

    if (HAS_TEXT_CONTAINER) {
        self.placeholderTextView.textContainer.exclusionPaths = self.textContainer.exclusionPaths;
        self.placeholderTextView.textContainer.lineFragmentPadding = self.textContainer.lineFragmentPadding;
    }

    if (HAS_TEXT_CONTAINER_INSETS(self)) {
        self.placeholderTextView.textContainerInset = self.textContainerInset;
    }

    if (_attributedPlaceholder) {
        self.placeholderTextView.attributedText = _attributedPlaceholder;
    } else if (_placeholder) {
        self.placeholderTextView.text = _placeholder;
    }

    [self setPlaceholderVisibleForText:self.text];

    self.clipsToBounds = YES;

    // some observations
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(textDidChange:)
                          name:UITextViewTextDidChangeNotification object:self];

    [self addObserver:self forKeyPath:kAttributedPlaceholderKey
              options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:kPlaceholderKey
              options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:kFontKey
              options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:kAttributedTextKey
              options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:kTextKey
              options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:kTextAlignmentKey
              options:NSKeyValueObservingOptionNew context:nil];

    if (HAS_TEXT_CONTAINER) {
        [self.textContainer addObserver:self forKeyPath:kExclusionPathsKey
                                options:NSKeyValueObservingOptionNew context:nil];
        [self.textContainer addObserver:self forKeyPath:kLineFragmentPaddingKey
                                options:NSKeyValueObservingOptionNew context:nil];
    }

    if (HAS_TEXT_CONTAINER_INSETS(self)) {
        [self addObserver:self forKeyPath:kTextContainerInsetKey
                  options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)setPlaceholder:(NSString *)placeholderText
{
    _placeholder = [placeholderText copy];
    _attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholderText];

    [self resizePlaceholderFrame];
}

- (void)setAttributedPlaceholder:(NSAttributedString *)attributedPlaceholderText
{
    _placeholder = attributedPlaceholderText.string;
    _attributedPlaceholder = [attributedPlaceholderText copy];

    [self resizePlaceholderFrame];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self resizePlaceholderFrame];
}

- (void)resizePlaceholderFrame
{
    CGRect frame = self.placeholderTextView.frame;
    frame.size = self.bounds.size;
    self.placeholderTextView.frame = frame;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:kAttributedPlaceholderKey]) {
        self.placeholderTextView.attributedText = [change valueForKey:NSKeyValueChangeNewKey];
    }
    else if ([keyPath isEqualToString:kPlaceholderKey]) {
        self.placeholderTextView.text = [change valueForKey:NSKeyValueChangeNewKey];
    }
    else if ([keyPath isEqualToString:kFontKey]) {
        self.placeholderTextView.font = [change valueForKey:NSKeyValueChangeNewKey];
    }
    else if ([keyPath isEqualToString:kAttributedTextKey]) {
        NSAttributedString *newAttributedText = [change valueForKey:NSKeyValueChangeNewKey];
        [self setPlaceholderVisibleForText:newAttributedText.string];
    }
    else if ([keyPath isEqualToString:kTextKey]) {
        NSString *newText = [change valueForKey:NSKeyValueChangeNewKey];
        [self setPlaceholderVisibleForText:newText];
    }
    else if ([keyPath isEqualToString:kExclusionPathsKey]) {
        self.placeholderTextView.textContainer.exclusionPaths = [change objectForKey:NSKeyValueChangeNewKey];
        [self resizePlaceholderFrame];
    }
    else if ([keyPath isEqualToString:kLineFragmentPaddingKey]) {
        self.placeholderTextView.textContainer.lineFragmentPadding = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        [self resizePlaceholderFrame];
    }
    else if ([keyPath isEqualToString:kTextContainerInsetKey]) {
        NSValue *value = [change objectForKey:NSKeyValueChangeNewKey];
        self.placeholderTextView.textContainerInset = value.UIEdgeInsetsValue;
    }
    else if ([keyPath isEqualToString:kTextAlignmentKey]) {
        NSNumber *alignment = [change objectForKey:NSKeyValueChangeNewKey];
        self.placeholderTextView.textAlignment = alignment.intValue;
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)setPlaceholderTextColor:(UIColor *)placeholderTextColor
{
    self.placeholderTextView.textColor = placeholderTextColor;
}

- (UIColor *)placeholderTextColor
{
    return self.placeholderTextView.textColor;
}

- (void)textDidChange:(NSNotification *)aNotification
{
    [self setPlaceholderVisibleForText:self.text];
}

- (BOOL)becomeFirstResponder
{
    [self setPlaceholderVisibleForText:self.text];

    return [super becomeFirstResponder];
}

- (void)setPlaceholderVisibleForText:(NSString *)text
{
    if (text.length < 1) {
        [self addSubview:self.placeholderTextView];
        [self sendSubviewToBack:self.placeholderTextView];
    } else {
        [self.placeholderTextView removeFromSuperview];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserver:self forKeyPath:kAttributedPlaceholderKey];
    [self removeObserver:self forKeyPath:kPlaceholderKey];
    [self removeObserver:self forKeyPath:kFontKey];
    [self removeObserver:self forKeyPath:kAttributedTextKey];
    [self removeObserver:self forKeyPath:kTextKey];
    [self removeObserver:self forKeyPath:kTextAlignmentKey];

    if (HAS_TEXT_CONTAINER) {
        [self.textContainer removeObserver:self forKeyPath:kExclusionPathsKey];
        [self.textContainer removeObserver:self forKeyPath:kLineFragmentPaddingKey];
    }

    if (HAS_TEXT_CONTAINER_INSETS(self)) {
        [self removeObserver:self forKeyPath:kTextContainerInsetKey];
    }
}

@end