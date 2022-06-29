"""
    squeeze_excite(inplanes, reduction = 16; rd_divisor = 8,
                   activation = relu, gate_activation = sigmoid, norm_layer = identity,
                   rd_planes = _round_channels(inplanes ÷ reduction, rd_divisor, 0.0))

Creates a squeeze-and-excitation layer used in MobileNets and SE-Nets.

# Arguments

  - `inplanes`: The number of input feature maps
  - `reduction`: The reduction factor for the number of hidden feature maps
  - `rd_divisor`: The divisor for the number of hidden feature maps.
  - `activation`: The activation function for the first convolution layer
  - `gate_activation`: The activation function for the gate layer
  - `norm_layer`: The normalization layer to be used after the convolution layers
  - `rd_planes`: The number of hidden feature maps in a squeeze and excite layer
    Must be ≥ 1 or `nothing` for no squeeze and excite layer.
"""
function squeeze_excite(inplanes; reduction = 16, rd_divisor = 8,
                        activation = relu, gate_activation = sigmoid, norm_layer = identity,
                        rd_planes = _round_channels(inplanes ÷ reduction, rd_divisor, 0.0))
    return SkipConnection(Chain(AdaptiveMeanPool((1, 1)),
                                Conv((1, 1), inplanes => rd_planes),
                                norm_layer,
                                activation,
                                Conv((1, 1), rd_planes => inplanes),
                                norm_layer,
                                gate_activation), .*)
end

"""
    effective_squeeze_excite(inplanes, gate_layer = sigmoid)

Effective squeeze-and-excitation layer.
(reference: [CenterMask : Real-Time Anchor-Free Instance Segmentation](https://arxiv.org/abs/1911.06667))
"""
function effective_squeeze_excite(inplanes; gate_activation = sigmoid, kwargs...)
    return SkipConnection(Chain(AdaptiveMeanPool((1, 1)),
                                Conv((1, 1), inplanes, inplanes),
                                gate_activation), .*)
end
